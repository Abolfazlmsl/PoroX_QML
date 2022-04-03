import sys
import os
import time
import shutil
import random
import string
import pickle
import openpnm as op
from openpnm.models import physics as mods
import openpnm.models.physics as pm
from os.path import abspath, dirname, join
from PIL import Image
import numpy as np
import scipy as sp
import scipy.ndimage as ndim
import segmentation
import cv2
from BlatralFilter import filter_bilateral
from scipy.interpolate import interp1d
import skimage
import itertools
import math
import mpslib as mps
from skimage.morphology import ball, disk, cube
from porespy.networks import _net_dict
from collections import namedtuple
from porespy.networks import add_boundary_regions
from porespy.tools import pad_faces, make_contiguous
import scipy.spatial as sptl
from scipy import stats
from skimage.morphology import watershed
import nrrd
from skimage.feature import peak_local_max

import skimage.filters.thresholding as sk

from PySide2.QtCore import QObject, Signal, Slot, QUrl, QRunnable, QThread, QEventLoop, QTimer, QThreadPool
from PySide2.QtWidgets import QApplication, QSplashScreen
from PySide2.QtQml import QQmlApplicationEngine
from PySide2.QtGui import QIcon, QPixmap
from stl import mesh
import skimage.measure as ms

from Relperm import RelativePermeability
from RelDiff import RelativeDiffusivity

from licensing.models import *
from licensing.methods import Key, Helpers

from getmac import get_mac_address as gma
import datetime
import requests

from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
import smtplib
import ssl

import webbrowser

from melipayamak import Api

application_path = (
    sys._MEIPASS
    if getattr(sys, "frozen", False)
    else dirname(abspath(__file__))
)

class Main(QObject):
    def __init__(self, storagepath):
        QObject.__init__(self)

        self.counter = 0
        self.total = 0
        self.inputType = None
        self.image = None
        self.im_denoise = None
        self.im_filter = None
        self.im_segment = None
        self.im_reconstruct = None
        self.stlimage = None
        self.showStlimage = None
        self.stlrecons = None
        self.resolution = None
        self.issnow = False
        self.ismb = False
        self.run = True
        self.onTimer = False
        self.change_state = "white"
        self.offlineStoragePath = storagepath
        self.x = 0
        self.y = 0
        self.z = 0

        self.xx = 0
        self.yy = 0
        self.zz = 0

        self.mins = 0
        self.sec = 0

        self.network = None
        self.backupNetwork = None
        self.backupGeometry = None
        self.getNetbackup = False
        self.getGeobackup = False
        self.geometry = None
        self.phase_inv = None
        self.phase_def = None

        self.project = {}

        self.threadpool = QThreadPool()
        self.threadpool.setMaxThreadCount(10)

    macData = Signal(str)
    device_id = Signal(int)
    trialData = Signal(int, list, str, bool)
    registCode = Signal(int)
#    timeLimitData = Signal(str)
    newFile = Signal()
    saveFile = Signal()
    openFile = Signal(str, float, float, float, float, float, list, list, list, list, str, int,
                      str, int, int, int, int, str, float, str, float, int, int,
                      int, int, int, int, list, list, str, float, float,
                      int, int, int, int, float, float, float, float, float, float, float, float, float,
                      list, list, list, list, list, list, list, list, list, list, list, list,
                      list, list, list, list, list, list, list, list, list, list, list, list,
                      list, list, list, list, list, list, list, list, list, list, list, list, list,
                      str, str, str, str, str, str, str, str, str, str, str, str, str, str, str, str,
                      str, str, str, str, str, str, str, str, str, str, str, str, str, str, str, str,
                      str, str, str, str, str, str, str, str, str, str, str, str, str, str, str, str,
                      str, str, str, str, str, str, str, str, str, str, str, str, str, str, str, str,
                      str, str, str, str, str, str, str, str, str, str, str, str, str, str, str, str,
                      str, str, str, str, str, str, str, str, str, str, str, str, str, str, str, str,
                      str, str, str, str, str, str, str, str, str, str, str, str, str, str, str, str,
                      str, str, str, str, str, str, str, str, str, str, str, str, str, str, str, str,
                      str, str, str, str, str, str, str, str, str, float, float, float, int, int, str)
    nextNumber = Signal(int, int)
    nextNumberBinary = Signal(int, int, float, list, list, list, list)
    nextNumberThinsection = Signal(int, int)
    next3DNumber = Signal(int, int, int, bool)
    next3DNumberBinary = Signal(int, int, int, float, list, list, list, list, bool)
    importImage = Signal(str)
    stopButton = Signal()
    changeBW = Signal(float, list, list, list, list)
    changePM = Signal()
    denoiseImage = Signal(str, bool)
    filterImage = Signal(str, str, str, str, bool)
    threshold = Signal(float, float, list, list, list, list, bool)
    message_Cubic = Signal(bool, float, float, float, list, list, list, list, list)
    message_CubicDual = Signal(bool, float, float, float, list, list, list, list, list)
    message_Bravais = Signal(bool, float, float, float, list, list, list, list, list)
    message_DelaunayVoronoiDual = Signal(bool, float, float, float, list, list, list, list, list)
    message_Voronoi = Signal(bool, float, float, float, list, list, list, list, list)
    message_Delaunay = Signal(bool, float, float, float, list, list, list, list, list)
    message_Gabriel = Signal(bool, float, float, float, list, list, list, list, list)
    reconstructStatisticalImage = Signal(float, list, list, bool)
    reconstructMPSImage = Signal(float)
    extractedSNOWNetwork = Signal(float, float, bool)
    extractedMaximalNetwork = Signal(float)
    finalsimulation = Signal(int, int, int, int, float, float, float, float, float, float, float, float, float,
                            list, list, list, list, list, list, list, list, list, list, list, list,
                            list, list, list, list, list, list, list, list, list, list, list, list,
                            list, list, list, list, list, list, list, list, list, list, list, list, list, bool)
    time = Signal(str, str)
    percent = Signal(int)

    @Slot()
    def enterLicense(self):
        mac = self.getMacAddress()
        self.macData.emit(mac)

    @Slot(int, str, str, str, str)
    def makeTrialData(self, time, token, base, urlLicense, urlDevice):
        mac = self.getMacAddress()
        device_id, keyData = self.postDevice(mac, token, base, urlLicense, urlDevice)
        date = self.getExpiredDate(time)

        if (mac == "00:00:00:00:00:00"):
            vpn = True
        else:
            vpn = False

        self.trialData.emit(device_id, keyData, date, vpn)

    @Slot(str)
    def makeLicenseKey(self, link):
        webbrowser.open(link)
        
    def getMacAddress(self):
        mac = gma()
        return mac
    
    def getExpiredDate(self, time):
        date = datetime.datetime.now() + datetime.timedelta(time)
        return date.strftime('%Y-%m-%d')

    def postDevice(self, mac, myToken, Base, urlLicense, urlDevice):
        headers = {
            'accept': 'application/json',
            'Authorization': 'Bearer '+ myToken,
        }
        r = requests.post(Base+urlDevice, json={"deviceMac": mac}, headers=headers)
        l = requests.get(Base+urlLicense, headers=headers)

        try:
            return r.json()['id'], l.json()
        except:
            return -1, []

    @Slot(str, str, str, str)
    def postDeviceSlot(self, mac, myToken, Base, urlDevice):
        headers = {
            'accept': 'application/json',
            'Authorization': 'Bearer '+ myToken,
        }
        r = requests.post(Base+urlDevice, json={"deviceMac": mac}, headers=headers)
        self.device_id.emit(r.json()['id'])
     

    @Slot(str)
    def sendSMS(self, phone):
        worker = Mythread_function_0(self.sendSMS_th, phone)
        self.threadpool.start(worker)

    @Slot(str)
    def sendSMS_th(self, phone):
        username = '09114113874'
        password = '9AL5O'
        api = Api(username, password)
        # sms = api.sms()
        # to = phone
        # _from = '50004000'
        # code = random.randint(10000, 99999)
        # text = "Thank you for installing the PoroX software.\nCode: " + str(code)
        # response = sms.send(to, _from, text)
        
        sms_soap = api.sms('soap')
        to = phone
        bodyId = 81109
        code = random.randint(10000, 99999)
        text = [str(code)]
        sms_soap.send_by_base_number(text, to, bodyId)

        self.registCode.emit(code)

    @Slot(str, str, str, str, str, str, str, str, str)
    def sendEmail(self, message, email, key, serial, adminurl, name, phone, education, job):
        worker = Mythread_function_7(self.sendEmail_th, message, email, key, serial, adminurl,
                                    name, phone, education, job)
        self.threadpool.start(worker)

    @Slot(str, str, str, str, str, str, str, str, str)
    def sendEmail_th(self, message, email, key, serial, adminurl, name, phone, education, job):
        msg = MIMEMultipart()

        password = "Porox@Sharif1" #"3@#abmsl@"
        msg['From'] = "reza.shams@digitalrockphysics.ir" #"poroxsoftware@gmail.com"
        msg['To'] = email
        msg['Subject'] = "PoroX license"

        message = message + "\nYour license key: " + key + "\nYour serial number: " + serial + "\nAfter reviewing your information, the admin will activate your license."
        msg.attach( MIMEText(message, 'plain') )

        context = ssl.create_default_context()
        server = smtplib.SMTP_SSL(host='mail.digitalrockphysics.ir', port=465, context=context)
        #server = smtplib.SMTP_SSL(host='smtp.gmail.com', port=465, context=context)
        #server.starttls()

        server.login(msg['From'], password)

        server.sendmail(msg['From'], msg['To'], msg.as_string())

        msgAdmin = MIMEMultipart()
        adminurl = adminurl + "/admin/"
        messageAdmin = "A new request for trial license key from:\nName: " + name +\
                        "\nPhone number: " + phone + "\nEmail: " + email +\
                        "\nEducation: " + education + "\nJob: " + job + "\nGo to " + adminurl + " for approval"
        msgAdmin.attach( MIMEText(messageAdmin, 'plain') )

        msgAdmin['From'] = "reza.shams@digitalrockphysics.ir"
        msgAdmin['ToAdmin1'] = 'rezashams70@gmail.com'
        msgAdmin['ToAdmin2'] = 'abolfazlmoslemipoor@gmail.com'
        msgAdmin['Subject'] = "PoroX license"

        server.sendmail(msgAdmin['From'], msgAdmin['ToAdmin1'], msgAdmin.as_string())
        server.sendmail(msgAdmin['From'], msgAdmin['ToAdmin2'], msgAdmin.as_string())

        server.quit()
        
    @Slot()
    def new_file(self):
        self.inputType = None
        self.image = None
        self.im_denoise = None
        self.im_filter = None
        self.im_segment = None
        self.im_reconstruct = None
        self.stlimage = None
        self.showStlimage = None
        self.stlrecons = None
        self.resolution = None
        self.issnow = False
        self.ismb = False
        self.run = True
        self.onTimer = False
        self.change_state = "white"
        self.x = 0
        self.y = 0
        self.z = 0

        self.xx = 0
        self.yy = 0
        self.zz = 0

        self.mins = 0
        self.sec = 0

        self.network = None
        self.backupNetwork = None
        self.backupGeometry = None
        self.getNetbackup = False
        self.getGeobackup = False
        self.geometry = None
        self.phase_inv = None
        self.phase_def = None

        self.project = {}

        self.newFile.emit()

    def to_stl(self, im, filename, downsample=True):
        filename = self.sanitize_filename(filename, ext="stl", exclude_ext=True)
        if len(im.shape) == 2:
            im = im[:, :, np.newaxis]
        vs = 1
        self.progress(1.5, 3, 3)
        if downsample:
            im = ndim.interpolation.zoom(im, zoom=0.5, order=0, mode="reflect")
            self.save_stl(im, vs * 2, filename)
        else:
            self.save_stl(im, vs, filename)
        self.progress(2, 3, 3)

    def sanitize_filename(self, filename, ext, exclude_ext=False):
        ext.strip(".")
        if filename.endswith(f".{ext}"):
            name = ".".join(filename.split(".")[:-1])
        else:
            name = filename
        filename_formatted = f"{name}" if exclude_ext else f"{name}.{ext}"
        return filename_formatted

    def save_stl(self, im, vs, filename):
        im = np.pad(im, pad_width=10, mode="constant", constant_values=True)
        vertices, faces, norms, values = ms.marching_cubes_lewiner(im)
        vertices *= vs
        # Export the STL file
        export = mesh.Mesh(np.zeros(faces.shape[0], dtype=mesh.Mesh.dtype))
        for i, f in enumerate(faces):
            for j in range(3):
                export.vectors[i][j] = vertices[f[j], :]
        export.save(self.offlineStoragePath + f"/{filename}.stl")

    @Slot(str)
    def save_file(self, filepath):
        self.path = filepath

        with open(self.path, 'wb') as project:
            pickle.dump(self.project, project)

        self.saveFile.emit()

    @Slot(str)
    def open_file(self, filepath):

        with open(filepath, 'rb') as rock_model:
            project = pickle.load(rock_model)

        xdata = []
        ydata = []
        Gxdata = []
        Gydata = []
        self.porosity = 0
        denoiseMethod = ""
        denoiseParam = ""
        filterMethod = ""
        filterParam1 = ""
        filterParam2 = ""
        filterParam3 = ""
        filterParam4 = ""
        segmentMethod = ""
        th = ""
        reconstructMethod = ""
        reconstructParam1 = ""
        reconstructParam2 = ""
        reconstructParam3 = ""
        reconstructParam4 = ""
        reconstructParam5 = ""
        reconstructParam6 = ""
        rporosity = ""
        S2_x = []
        S2_y = []
        extractionMethod = ""
        extractionParam1 = ""
        extractionParam2 = ""
        overal_pores = ""
        connected_pores = ""
        isolated_pores = ""
        overal_throats = ""
        self.porosity = ""
        self.K_tot = ""
        K1 = ""
        K2 = ""
        K3 = ""
        D_tot = ""
        D1 = ""
        D2 = ""
        D3 = ""
        x_eval = []
        y_eval = []
        x_eval2 = []
        y_eval2 = []
        coordination_x = []
        coordination_y = []
        PC_data = {}
        PC_data['SWx'] = ""
        PC_data['SWy'] = ""
        PC_data['SWz'] = ""
        PC_data['PCx'] = ""
        PC_data['PCy'] = ""
        PC_data['PCz'] = ""

        Krdata = {}
        Krdata['Swx'] = ""
        Krdata['Swy'] = ""
        Krdata['Swz'] = ""
        Krdata['Krwx'] = ""
        Krdata['Krwy'] = ""
        Krdata['Krwz'] = ""
        Krdata['Krnwx'] = ""
        Krdata['Krnwy'] = ""
        Krdata['Krnwz'] = ""

        Drdata = {}
        Drdata['Swx'] = ""
        Drdata['Swy'] = ""
        Drdata['Swz'] = ""
        Drdata['Drwx'] = ""
        Drdata['Drwy'] = ""
        Drdata['Drwz'] = ""
        Drdata['Drnwx'] = ""
        Drdata['Drnwy'] = ""
        Drdata['Drnwz'] = ""

        radius = []
        pcoord = []
        throatradius = []
        throatlen = []
        tcenter = []
        rotationAxis = []
        angle = []

        porediam = ""
        poreseed = ""
        poresurf = ""
        porevol = ""
        porearea = ""
        throatdiam = ""
        throatseed = ""
        throatsurf = ""
        throatvol = ""
        throatarea = ""
        throatendpoint = ""
        throatlength = ""
        throatperim = ""
        throatshape = ""
        throatcentroid = ""
        throatvec = ""
        capillarypressure = ""
        diffusiveconductance = ""
        hydraulicconductance = ""
        multiphase = ""
        flowshape = ""
        poissonshape = ""
        phase_inv = ""
        phase_def = ""
        den_inv = ""
        den_def = ""
        diff_inv = ""
        diff_def = ""
        elec_inv = ""
        elec_def = ""
        mix_inv = ""
        mix_def = ""
        molar_inv = ""
        molar_def = ""
        partcoeff_inv = ""
        partcoeff_def = ""
        permittivity_inv = ""
        permittivity_def = ""
        surf_inv = ""
        surf_def = ""
        vapor_inv = ""
        vapor_def = ""
        vis_inv = ""
        vis_def = ""
        concentration_inv = ""
        concentration_def = ""
        pressure_inv = ""
        pressure_def = ""
        temp_inv = ""
        temp_def = ""
        moldiffvol_inv = ""
        moldiffvol_def = ""
        volfrac_inv = ""
        volfrac_def = ""
        intcond_inv = ""
        intcond_def = ""
        molweight_inv = ""
        molweight_def = ""
        critemp_inv = ""
        critemp_def = ""
        cripressure_inv = ""
        cripressure_def = ""
        crivol_inv = ""
        crivol_def = ""
        criangle_inv = ""
        criangle_def = ""
        poreshape = ""
        porescale = ""
        poreloc = ""
        poremode = ""
        poreweightx = ""
        poreweighty = ""
        poreweightz = ""
        throatShape = ""
        throatscale = ""
        throatloc = ""
        throatmode = ""
        invadeMWA = ""
        invadeMWB = ""
        invadeatomicvolA = ""
        invadeatomicvolB = ""
        invadediffcoeff = ""
        invademolvolA = ""
        invademolvolB = ""
        invadesurfA = ""
        invadesurfB = ""
        invadeperrelexp = ""
        invadedickey = ""
        invadechemicalformula = ""
        invadeconstparam = ""
        invadeK2 = ""
        invadeN = ""
        invadesurfprop = ""
        invadeprescoeffA = ""
        invadeprescoeffB = ""
        invadeprescoeffC = ""
        invadeviscoeffA = ""
        invadeviscoeffB = ""
        defendMWA = ""
        defendMWB = ""
        defendatomicvolA = ""
        defendatomicvolB = ""
        defenddiffcoeff = ""
        defendmolvolA = ""
        defendmolvolB = ""
        defendsurfA = ""
        defendsurfB = ""
        defendperrelexp = ""
        defenddickey = ""
        defendchemicalformula = ""
        defendconstparam = ""
        defendK2 = ""
        defendN = ""
        defendsurfprop = ""
        defendprescoeffA = ""
        defendprescoeffB = ""
        defendprescoeffC = ""
        defendviscoeffA = ""
        defendviscoeffB = ""
        method = ""
        residual = ""
        trapping = ""
        invadedensityU = ""
        invadediffusivityU = ""
        invadesalinityU = ""
        invademolardenU = ""
        invadesurfU = ""
        invadevaporU = ""
        invadevisU = ""
        defenddensityU = ""
        defenddiffusivityU = ""
        defendsalinityU = ""
        defendmolardenU = ""
        defendsurfU = ""
        defendvaporU = ""
        defendvisU = ""

        constructmethod = ""
        x_spa = ""
        y_spa = ""
        z_spa = ""
        connect = ""
        nump = ""
        mode = ""

        if (project.get('type') is not None):
            if (project.get('type') == "Synthetic Network"):
                self.inputType = project['type']
                self.x = float(project['xdim'])
                self.y = float(project['ydim'])
                self.z = float(project['zdim'])
                constructmethod = project['constructmethod']
                x_spa = project['constructparam1']
                y_spa = project['constructparam2']
                z_spa = project['constructparam3']
                connect = project['constructparam4']
                nump = project['constructparam5']
                mode = project['constructparam6']
                pcoord = project['pcoord']
                throatlen = project['throatlen']
                tcenter = project['tcenter']
                rotationAxis = project['rotationAxis']
                angle = project['angle']
                self.getNetbackup = True
                self.getGeobackup = True
            else:
                self.inputType = project['type']
                self.x = int(project['xdim'])
                self.y = int(project['ydim'])
                self.z = int(project['zdim'])
                self.resolution = float(project['resolution'])

                self.stlimage = project['stlimage']
                self.showStlimage = np.copy(self.stlimage)
                self.to_stl(self.stlimage, filename="main")

                save_image = project['savemimage']
                # Save image to localstorage
                if "3D" in self.inputType:
                    is3D = True
                else:
                    is3D = False

                if is3D:
                    save_image = np.array(save_image, dtype=np.uint8)
                    for i in range(save_image.shape[2]):
                        saveimage = Image.fromarray(save_image[:,:,i])
                        if i<=8:
                            saveimage.save(self.offlineStoragePath + '/MImages/M000' + str(i+1) + '.png')
                        elif i>8 and i<=98:
                            saveimage.save(self.offlineStoragePath + '/MImages/M00' + str(i+1) + '.png')
                        else:
                            saveimage.save(self.offlineStoragePath + '/MImages/M0' + str(i+1) + '.png')
                else:
                    if (self.inputType != "2D Thinsection"):
                        save_image = np.array(save_image)
                        save_image = Image.fromarray(save_image)
                        save_image.convert("RGB")
                        save_image.save(self.offlineStoragePath + '/MImages/M0001.png')
                    else:
                        save_image = np.array(save_image, dtype=np.uint8)
                        save_image = Image.fromarray(save_image)
                        save_image.save(self.offlineStoragePath + '/MImages/M0001.png')

                self.image = project['mainimage']
                self.image = np.array(self.image, dtype=np.uint8)

                if (project.get('denoisemethod') is not None):
                    denoiseMethod = project['denoisemethod']
                    save_image = project['savedimage']
                    denoiseParam = project['denoiseParam']

                    if is3D:
                        save_image = np.array(save_image, dtype=np.uint8)
                        for i in range(save_image.shape[2]):
                            saveimage = Image.fromarray(save_image[:,:,i])
                            if i<=8:
                                saveimage.save(self.offlineStoragePath + '/DImages/M000' + str(i+1) + '.png')
                            elif i>8 and i<=98:
                                saveimage.save(self.offlineStoragePath + '/DImages/M00' + str(i+1) + '.png')
                            else:
                                saveimage.save(self.offlineStoragePath + '/DImages/M0' + str(i+1) + '.png')
                    else:
                        save_image = np.array(save_image, dtype=np.uint8)
                        save_image = Image.fromarray(save_image)
                        save_image.save(self.offlineStoragePath + '/DImages/M0001.png')

                    self.im_denoise = project['dimage']

                if (project.get('filtermethod') is not None):
                    filterMethod = project['filtermethod']
                    save_image = project['savefimage']
                    filterParam1 = project['filterParam1']
                    filterParam2 = project['filterParam2']
                    filterParam3 = project['filterParam3']
                    filterParam4 = project['filterParam4']

                    if is3D:
                        save_image = np.array(save_image, dtype=np.uint8)
                        for i in range(save_image.shape[2]):
                            saveimage = Image.fromarray(save_image[:,:,i])
                            if i<=8:
                                saveimage.save(self.offlineStoragePath + '/FImages/M000' + str(i+1) + '.png')
                            elif i>8 and i<=98:
                                saveimage.save(self.offlineStoragePath + '/FImages/M00' + str(i+1) + '.png')
                            else:
                                saveimage.save(self.offlineStoragePath + '/FImages/M0' + str(i+1) + '.png')
                    else:
                        save_image = np.array(save_image, dtype=np.uint8)
                        save_image = Image.fromarray(save_image)
                        save_image.save(self.offlineStoragePath + '/FImages/M0001.png')

                    self.im_filter = project['fimage']

                if (project.get('simage') is not None):
                    self.im_segment = project['simage']
                    self.im_segment = np.array(self.im_segment, dtype=np.uint8)
                    self.porosity = float(project['imageporosity'])

                    if (self.inputType == "3D Gray" or self.inputType == "2D Gray" or self.inputType == "2D Thinsection"):
                        segmentMethod = project['segmentmethod']
                        saveimage = project['savesimage']
                        th = project['segmentParam']
                        self.stlimage = project['stlimage']
                        self.to_stl(self.stlimage, filename="main")

                        if is3D:
                            save_image = np.array(saveimage, dtype=np.uint8)
                            for i in range(self.im_segment.shape[2]):
                                saveimage = Image.fromarray(save_image[:,:,i])
                                if i<=8:
                                    saveimage.save(self.offlineStoragePath + '/SImages/M000' + str(i+1) + '.png')
                                elif i>8 and i<=98:
                                    saveimage.save(self.offlineStoragePath + '/SImages/M00' + str(i+1) + '.png')
                                else:
                                    saveimage.save(self.offlineStoragePath + '/SImages/M0' + str(i+1) + '.png')
                        else:
                            save_image = np.array(saveimage, dtype=np.uint8)
                            save_image = Image.fromarray(save_image)
                            save_image.save(self.offlineStoragePath + '/SImages/M0001.png')

                    xdata = project['psdimagex']
                    ydata = project['psdimagey']
                    Gxdata = project['gsdimagex']
                    Gydata = project['gsdimagey']
                    self.radius_p = project['radius_p']
                    self.radius_g = project['radius_g']

                if (project.get('rimage') is not None):
                    if (project.get('reconstructmethod') == "Statistical"):
                        reconstructMethod = "Statistical"
                        save_image = project['saverimage']
                        reconstructParam1 = int(project['reconstructparam1'])
                        reconstructParam2 = int(project['reconstructparam2'])
                        reconstructParam3 = int(project['reconstructparam3'])
                        reconstructParam4 = int(project['reconstructparam4'])

                        saveimage = np.array(save_image, dtype=np.uint8)
                        for i in range(saveimage.shape[2]):
                            saveRimage = Image.fromarray(saveimage[:,:,i])
                            if i<=8:
                                saveRimage.save(self.offlineStoragePath + '/RImages/M000' + str(i+1) + '.png')
                            elif i>8 and i<=98:
                                saveRimage.save(self.offlineStoragePath + '/RImages/M00' + str(i+1) + '.png')
                            else:
                                saveRimage.save(self.offlineStoragePath + '/RImages/M0' + str(i+1) + '.png')

                        self.im_reconstruct = project['rimage']
                        rporosity = float(project['reconstructporosity'])
                        S2_x = project['s2imagex']
                        S2_y = project['s2imagey']
                        self.stlrecons = project['stlrecons']
                        self.to_stl(self.stlrecons, filename="reconstruct")
                    else:
                        reconstructMethod = "MPS"
                        save_image = project['saverimage']
                        reconstructParam1 = int(project['reconstructparam1'])
                        reconstructParam2 = int(project['reconstructparam2'])
                        reconstructParam3 = int(project['reconstructparam3'])
                        reconstructParam4 = int(project['reconstructparam4'])
                        reconstructParam5 = int(project['reconstructparam5'])
                        reconstructParam6 = int(project['reconstructparam6'])

                        saveimage = np.array(save_image, dtype=np.uint8)
                        for i in range(saveimage.shape[2]):
                            saveRimage = Image.fromarray(saveimage[:,:,i])
                            if i<=8:
                                saveRimage.save(self.offlineStoragePath + '/RImages/M000' + str(i+1) + '.png')
                            elif i>8 and i<=98:
                                saveRimage.save(self.offlineStoragePath + '/RImages/M00' + str(i+1) + '.png')
                            else:
                                saveRimage.save(self.offlineStoragePath + '/RImages/M0' + str(i+1) + '.png')

                        self.im_reconstruct = project['rimage']
                        rporosity = float(project['reconstructporosity'])
                        self.stlrecons = project['stlrecons']
                        self.to_stl(self.stlrecons, filename="reconstruct")

                if (project.get('extractionmethod') is not None):
                    if (project.get('extractionmethod') == "SNOW"):
                        extractionMethod = "SNOW"
                        extractionParam1 = float(project['extractionparam1'])
                        extractionParam2 = float(project['extractionparam2'])

                        project['network'] = dict(project['network'])
                        self.network = op.network.GenericNetwork(name=''.join(random.choices(string.ascii_uppercase, k=15)))
                        self.network.update(project['network'])
                    else:
                        extractionMethod = "Maximal"
                        extractionParam1 = float(project['extractionparam1'])

                        project['network'] = dict(project['network'])
                        self.network = op.network.GenericNetwork(name=''.join(random.choices(string.ascii_uppercase, k=15)))
                        self.network.update(project['network'])
                    self.getNetbackup = True
                    self.getGeobackup = True

            if (project.get('finalnetwork') is not None):
                self.network = None
                project['finalnetwork'] = dict(project['finalnetwork'])
                self.network = op.network.GenericNetwork(name=''.join(random.choices(string.ascii_uppercase, k=15)))
                self.network.update(project['finalnetwork'])

                project['geometry'] = dict(project['geometry'])
                self.geometry = op.geometry.GenericGeometry(network=self.network,
                                                            pores=self.network.Ps,
                                                            throats=self.network.Ts,
                                                            name=''.join(random.choices(string.ascii_uppercase, k=15)))
                self.geometry.update(project['geometry'])

                self.backupNetwork = op.network.GenericNetwork(name=''.join(random.choices(string.ascii_uppercase, k=15)))
                self.backupNetwork.update(project['backupnetwork'])

                project['backupgeometry'] = dict(project['backupgeometry'])
                self.backupGeometry = op.geometry.GenericGeometry(network=self.backupNetwork,
                                                            pores=self.backupNetwork.Ps,
                                                            throats=self.backupNetwork.Ts,
                                                            name=''.join(random.choices(string.ascii_uppercase, k=15)))
                self.backupGeometry.update(project['backupgeometry'])

                project['phaseinv'] = dict(project['phaseinv'])
                self.phase_inv = op.phases.GenericPhase(network=self.network,
                                                        name=''.join(random.choices(string.ascii_uppercase, k=15)))
                self.phase_inv.update(project['phaseinv'])
                project['phasedef'] = dict(project['phasedef'])
                self.phase_def = op.phases.GenericPhase(network=self.network,
                                                        name=''.join(random.choices(string.ascii_uppercase, k=15)))
                self.phase_def.update(project['phasedef'])

                project['physinv'] = dict(project['physinv'])
                self.phys_inv = op.physics.GenericPhysics(network=self.network,
                                                      phase=self.phase_inv,
                                                      geometry=self.geometry,
                                                      name=''.join(random.choices(string.ascii_uppercase, k=15)))
                self.phys_inv.update(project['physinv'])
                project['physdef'] = dict(project['physdef'])
                self.phys_def = op.physics.GenericPhysics(network=self.network,
                                                      phase=self.phase_def,
                                                      geometry=self.geometry,
                                                      name=''.join(random.choices(string.ascii_uppercase, k=15)))
                self.phys_def.update(project['physdef'])

                overal_pores = int(project['overalpores'])
                connected_pores = int(project['connectedpores'])
                isolated_pores = int(project['isolatedpores'])
                overal_throats = int(project['overalthroats'])
                self.porosity = float(project['netporosity'])
                self.K_tot = float(project['K_tot'])
                K1 = float(project['K1'])
                K2 = float(project['K2'])
                K3 = float(project['K3'])
                D_tot = float(project['D_tot'])
                D1 = float(project['D1'])
                D2 = float(project['D2'])
                D3 = float(project['D3'])

                x_eval = project['xeval']
                y_eval = project['yeval']
                x_eval2 = project['xeval2']
                y_eval2 = project['yeval2']
                coordination_x = project['coordinationx']
                coordination_y = project['coordinationy']

                PC_data = {}
                PC_data['SWx'] = project['pcswx']
                PC_data['SWy'] = project['pcswy']
                PC_data['SWz'] = project['pcswz']
                PC_data['PCx'] = project['pcx']
                PC_data['PCy'] = project['pcy']
                PC_data['PCz'] = project['pcz']

                Krdata = {}
                Krdata['Swx'] = project['Krswx']
                Krdata['Swy'] = project['Krswy']
                Krdata['Swz'] = project['Krswz']
                Krdata['Krwx'] = project['Krwx']
                Krdata['Krwy'] = project['Krwy']
                Krdata['Krwz'] = project['Krwz']
                Krdata['Krnwx'] = project['Krnwx']
                Krdata['Krnwy'] = project['Krnwy']
                Krdata['Krnwz'] = project['Krnwz']

                Drdata = {}
                Drdata['Swx'] = project['Drswx']
                Drdata['Swy'] = project['Drswy']
                Drdata['Swz'] = project['Drswz']
                Drdata['Drwx'] = project['Drwx']
                Drdata['Drwy'] = project['Drwy']
                Drdata['Drwz'] = project['Drwz']
                Drdata['Drnwx'] = project['Drnwx']
                Drdata['Drnwy'] = project['Drnwy']
                Drdata['Drnwz'] = project['Drnwz']
                self.getGeobackup = False
                self.getNetbackup = False

                radius = project['radius']
                pcoord = project['pcoord']
                throatradius = project['throatradius']
                throatlen = project['throatlen']
                tcenter = project['tcenter']
                rotationAxis = project['rotationAxis']
                angle = project['angle']

                porediam = project['porediam']
                poreseed = project['poreseed']
                poresurf = project['poresurf']
                porevol = project['porevol']
                porearea = project['porearea']
                throatdiam = project['throatdiam']
                throatseed = project['throatseed']
                throatsurf = project['throatsurf']
                throatvol = project['throatvol']
                throatarea = project['throatarea']
                throatendpoint = project['throatendpoint']
                throatlength = project['throatlength']
                throatperim = project['throatperim']
                throatshape = project['throatshape']
                throatcentroid = project['throatcentroid']
                throatvec = project['throatvec']
                capillarypressure = project['capillarypressure']
                diffusiveconductance = project['diffusiveconductance']
                hydraulicconductance = project['hydraulicconductance']
                multiphase = project['multiphase']
                flowshape = project['flowshape']
                poissonshape = project['poissonshape']
                phase_inv = project['phase_inv']
                phase_def = project['phase_def']
                den_inv = project['den_inv']
                den_def = project['den_def']
                diff_inv = project['diff_inv']
                diff_def = project['diff_def']
                elec_inv = project['elec_inv']
                elec_def = project['elec_def']
                mix_inv = project['mix_inv']
                mix_def = project['mix_def']
                molar_inv = project['molar_inv']
                molar_def = project['molar_def']
                partcoeff_inv = project['partcoeff_inv']
                partcoeff_def = project['partcoeff_def']
                permittivity_inv = project['permittivity_inv']
                permittivity_def = project['permittivity_def']
                surf_inv = project['surf_inv']
                surf_def = project['surf_def']
                vapor_inv = project['vapor_inv']
                vapor_def = project['vapor_def']
                vis_inv = project['vis_inv']
                vis_def = project['vis_def']
                concentration_inv = project['concentration_inv']
                concentration_def = project['concentration_def']
                pressure_inv = project['pressure_inv']
                pressure_def = project['pressure_def']
                temp_inv = project['temp_inv']
                temp_def = project['temp_def']
                moldiffvol_inv = project['moldiffvol_inv']
                moldiffvol_def = project['moldiffvol_def']
                volfrac_inv = project['volfrac_inv']
                volfrac_def = project['volfrac_def']
                intcond_inv = project['intcond_inv']
                intcond_def = project['intcond_def']
                molweight_inv = project['molweight_inv']
                molweight_def = project['molweight_def']
                critemp_inv = project['critemp_inv']
                critemp_def = project['critemp_def']
                cripressure_inv = project['cripressure_inv']
                cripressure_def = project['cripressure_def']
                crivol_inv = project['crivol_inv']
                crivol_def = project['crivol_def']
                criangle_inv = project['criangle_inv']
                criangle_def = project['criangle_def']
                poreshape = project['poreshape']
                porescale = project['porescale']
                poreloc = project['poreloc']
                poremode = project['poremode']
                poreweightx = project['poreweightx']
                poreweighty = project['poreweighty']
                poreweightz = project['poreweightz']
                throatShape = project['throatShape']
                throatscale = project['throatscale']
                throatloc = project['throatloc']
                throatmode = project['throatmode']
                invadeMWA = project['invadeMWA']
                invadeMWB = project['invadeMWB']
                invadeatomicvolA = project['invadeatomicvolA']
                invadeatomicvolB = project['invadeatomicvolB']
                invadediffcoeff = project['invadediffcoeff']
                invademolvolA = project['invademolvolA']
                invademolvolB = project['invademolvolB']
                invadesurfA = project['invadesurfA']
                invadesurfB = project['invadesurfB']
                invadeperrelexp = project['invadeperrelexp']
                invadedickey = project['invadedickey']
                invadechemicalformula = project['invadechemicalformula']
                invadeconstparam = project['invadeconstparam']
                invadeK2 = project['invadeK2']
                invadeN = project['invadeN']
                invadesurfprop = project['invadesurfprop']
                invadeprescoeffA = project['invadeprescoeffA']
                invadeprescoeffB = project['invadeprescoeffB']
                invadeprescoeffC = project['invadeprescoeffC']
                invadeviscoeffA = project['invadeviscoeffA']
                invadeviscoeffB = project['invadeviscoeffB']
                defendMWA = project['defendMWA']
                defendMWB = project['defendMWB']
                defendatomicvolA = project['defendatomicvolA']
                defendatomicvolB = project['defendatomicvolB']
                defenddiffcoeff = project['defenddiffcoeff']
                defendmolvolA = project['defendmolvolA']
                defendmolvolB = project['defendmolvolB']
                defendsurfA = project['defendsurfA']
                defendsurfB = project['defendsurfB']
                defendperrelexp = project['defendperrelexp']
                defenddickey = project['defenddickey']
                defendchemicalformula = project['defendchemicalformula']
                defendconstparam = project['defendconstparam']
                defendK2 = project['defendK2']
                defendN = project['defendN']
                defendsurfprop = project['defendsurfprop']
                defendprescoeffA = project['defendprescoeffA']
                defendprescoeffB = project['defendprescoeffB']
                defendprescoeffC = project['defendprescoeffC']
                defendviscoeffA = project['defendviscoeffA']
                defendviscoeffB = project['defendviscoeffB']
                method = project['method']
                residual = project['residual']
                trapping = project['trapping']
                invadedensityU = project['invadedensityU']
                invadediffusivityU = project['invadediffusivityU']
                invadesalinityU = project['invadesalinityU']
                invademolardenU = project['invademolardenU']
                invadesurfU = project['invadesurfU']
                invadevaporU = project['invadevaporU']
                invadevisU = project['invadevisU']
                defenddensityU = project['defenddensityU']
                defenddiffusivityU = project['defenddiffusivityU']
                defendsalinityU = project['defendsalinityU']
                defendmolardenU = project['defendmolardenU']
                defendsurfU = project['defendsurfU']
                defendvaporU = project['defendvaporU']
                defendvisU = project['defendvisU']

            self.openFile.emit(self.inputType, self.x, self.y, self.z, self.resolution,
                               self.porosity, xdata, ydata, Gxdata, Gydata, denoiseMethod,
                               denoiseParam, filterMethod, filterParam1, filterParam2,
                               filterParam3, filterParam4, segmentMethod, th, reconstructMethod,
                               rporosity, reconstructParam1, reconstructParam2 ,reconstructParam3, reconstructParam4,
                               reconstructParam5, reconstructParam6, S2_x, S2_y,
                               extractionMethod, extractionParam1, extractionParam2,
                               overal_pores, connected_pores, isolated_pores,
                               overal_throats, self.porosity, self.K_tot, K1, K2, K3, D_tot, D1, D2, D3,
                               x_eval, y_eval, x_eval2, y_eval2, coordination_x, coordination_y,
                               PC_data['SWx'], PC_data['SWy'], PC_data['SWz'], PC_data['PCx'],
                               PC_data['PCy'], PC_data['PCz'],
                               Krdata['Swx'], Krdata['Swy'], Krdata['Swz'], Krdata['Krwx'], Krdata['Krnwx'],
                               Krdata['Krwy'], Krdata['Krnwy'], Krdata['Krwz'], Krdata['Krnwz'],
                               Drdata['Swx'], Drdata['Swy'], Drdata['Swz'],
                               Drdata['Drwx'], Drdata['Drnwx'], Drdata['Drwy'],
                               Drdata['Drnwy'], Drdata['Drwz'], Drdata['Drnwz'],
                               radius, pcoord, throatradius, throatlen, tcenter, rotationAxis, angle,
                               porediam, poreseed, poresurf, porevol, porearea, throatdiam, throatseed,
                               throatsurf, throatvol, throatarea, throatendpoint, throatlength, throatperim, throatshape,
                               throatcentroid, throatvec, capillarypressure, diffusiveconductance, hydraulicconductance, multiphase, flowshape,
                               poissonshape, phase_inv, phase_def, den_inv, den_def, diff_inv, diff_def, elec_inv, elec_def,
                               mix_inv, mix_def, molar_inv, molar_def, partcoeff_inv, partcoeff_def, permittivity_inv,
                               permittivity_def, surf_inv, surf_def, vapor_inv, vapor_def, vis_inv, vis_def, concentration_inv,
                               concentration_def, pressure_inv, pressure_def, temp_inv, temp_def, moldiffvol_inv, moldiffvol_def,
                               volfrac_inv, volfrac_def, intcond_inv, intcond_def, molweight_inv, molweight_def, critemp_inv, critemp_def,
                               cripressure_inv, cripressure_def, crivol_inv, crivol_def, criangle_inv, criangle_def, poreshape, porescale, poreloc, poremode, poreweightx, poreweighty,
                               poreweightz, throatShape, throatscale, throatloc, throatmode, invadeMWA, invadeMWB, invadeatomicvolA,
                               invadeatomicvolB, invadediffcoeff, invademolvolA, invademolvolB, invadesurfA, invadesurfB, invadeperrelexp,
                               invadedickey, invadechemicalformula, invadeconstparam, invadeK2, invadeN, invadesurfprop, invadeprescoeffA,
                               invadeprescoeffB, invadeprescoeffC, invadeviscoeffA, invadeviscoeffB, defendMWA, defendMWB, defendatomicvolA,
                               defendatomicvolB, defenddiffcoeff, defendmolvolA, defendmolvolB, defendsurfA, defendsurfB, defendperrelexp,
                               defenddickey, defendchemicalformula, defendconstparam, defendK2, defendN, defendsurfprop, defendprescoeffA,
                               defendprescoeffB, defendprescoeffC, defendviscoeffA, defendviscoeffB, method, residual, trapping,
                               invadedensityU, invadediffusivityU, invadesalinityU, invademolardenU, invadesurfU, invadevaporU,
                               invadevisU, defenddensityU, defenddiffusivityU, defendsalinityU, defendmolardenU, defendsurfU, defendvaporU,
                               defendvisU, constructmethod, x_spa, y_spa, z_spa, connect, nump, mode)


    ## -- Get the 2D Gray image -- ##
    @Slot(str, str)
    def get2DImage(self, url, resolution):
        self.z = 1
        self.resolution = float(resolution)

        img = Image.open(url)

        b = img.mode
        if "RGB" in b:
            img = img.convert("L")
        elif "16" in b:
            ims = np.array(img.getdata()).reshape(img.size[::-1])
            img = (np.array(ims, np.float)-np.min(ims))*255.0 / np.max(ims)-np.min(ims)

        img = np.array(img, dtype=np.uint8)
        # Save image to localstorage
        save_image = Image.fromarray(img)
        save_image.save(self.offlineStoragePath + '/MImages/M0001.png')

        img = np.transpose(img, (1, 0))
        img = np.fliplr(img)

        self.image = np.copy(img)
        self.x, self.y = np.shape(self.image)

        #For Qt3D display
        threshold_k, segment_show = segmentation.binarize_globalThreshold(img, 'otsu')
        segment_show = ~segment_show * 255

        #Attach dual segment_show images together to make a 3d image
        self.stlimage = np.zeros((segment_show.shape[0], segment_show.shape[1], 2))
        self.stlimage[:,:,0] = segment_show
        self.stlimage[:,:,1] = segment_show
        self.showStlimage = np.copy(self.stlimage)
        self.to_stl(self.stlimage, filename="main")

        self.inputType = "2D Gray"

        #################################Save Data#############################
        self.project['type'] = self.inputType
        self.project['xdim'] = self.x
        self.project['ydim'] = self.y
        self.project['zdim'] = self.z
        self.project['resolution'] = self.resolution
        self.project['stlimage'] = self.stlimage
        self.project['savemimage'] = save_image
        self.project['mainimage'] = self.image
        #######################################################################

        self.nextNumber.emit(self.x, self.y)


    ## -- Get the 2D Binary image -- ##
    @Slot(str, str)
    def get2DImageBinary(self, url, resolution):
        self.z = 1
        self.resolution = float(resolution)

        img = Image.open(url)

        b = img.mode
        if "RGB" in b:
            img = img.convert("L")
        elif "16" in b:
            ims = np.array(img.getdata()).reshape(img.size[::-1])
            img = (np.array(ims, np.float)-np.min(ims))*255.0 / np.max(ims)-np.min(ims)

        img = np.array(img, dtype=np.uint8)

        img = np.transpose(img, (1, 0))
        img = np.fliplr(img)

        save_image = np.transpose(img, (1, 0))
        save_image = np.flipud(save_image)
        # Save image to localstorage
        save_image = Image.fromarray(save_image)
        save_image.save(self.offlineStoragePath + '/MImages/M0001.png')

        self.image = np.copy(img)
        self.x, self.y = np.shape(img)

        self.image = np.array(~self.image, dtype=bool)
        self.image = self.image * 255
        self.image = np.array(self.image, dtype=np.uint8)
        self.im_segment = np.copy(self.image)
        poro_im = np.array(self.image)
        pore = np.count_nonzero(poro_im==255)
        self.porosity = pore/(self.x*self.y)*100
        self.porosity = round(self.porosity,2)

        state, xdata, ydata = self.PSD_image(self.im_segment)
        xdata = [float(i) for i in xdata]
        ydata = [float(i) for i in ydata]

        state, Gxdata, Gydata = self.GSD_image(self.im_segment)
        Gxdata = [float(i) for i in Gxdata]
        Gydata = [float(i) for i in Gydata]

        img = np.array(self.im_segment, dtype=bool)
        img = ~img
        img = img * 255
        img = np.array(img, dtype=np.uint8)

        #For Qt3D display (attach dual self.segment images together to make a 3d image)
        self.stlimage = np.zeros((img.shape[0], img.shape[1], 2))
        self.stlimage[:,:,0] = img
        self.stlimage[:,:,1] = img
        self.showStlimage = np.copy(self.stlimage)
        self.to_stl(self.stlimage, filename="main")
        self.inputType = "2D Binary"

        #################################Save Data#############################
        self.project['type'] = self.inputType
        self.project['xdim'] = self.x
        self.project['ydim'] = self.y
        self.project['zdim'] = self.z
        self.project['resolution'] = self.resolution
        self.project['stlimage'] = self.stlimage
        self.project['savemimage'] = save_image
        self.project['mainimage'] = self.image
        self.project['simage'] = self.im_segment
        self.project['psdimagex'] = xdata
        self.project['psdimagey'] = ydata
        self.project['gsdimagex'] = Gxdata
        self.project['gsdimagey'] = Gydata
        self.project['imageporosity'] = self.porosity
        #######################################################################

        self.nextNumberBinary.emit(self.x, self.y, self.porosity, xdata, ydata, Gxdata, Gydata)

    ## -- Get the 2D Thinsection image -- ##
    @Slot(str, str)
    def get2DImageThinsection(self, url, resolution):
        self.z = 1
        self.resolution = float(resolution)

        img = Image.open(url)

        # Save image to localstorage
        img.save(self.offlineStoragePath + '/MImages/M0001.png')

        b = img.mode
        if "RGB" in b:
            mainimg = img.convert("L")
        elif "16" in b:
            ims = np.array(mainimg.getdata()).reshape(mainimg.size[::-1])
            mainimg = (np.array(ims, np.float)-np.min(ims))*255.0 / np.max(ims)-np.min(ims)

        mainimg = np.array(mainimg, dtype=np.uint8)
        mainimg = np.transpose(mainimg, (1, 0))
        mainimg = np.fliplr(mainimg)

        self.image = np.copy(mainimg)
        self.x, self.y = np.shape(self.image)

        #For Qt3D display
        threshold_k, segment_show = segmentation.binarize_globalThreshold(mainimg, 'otsu')
        segment_show = ~segment_show * 255

        #Attach dual segment_show images together to make a 3d image
        self.stlimage = np.zeros((segment_show.shape[0], segment_show.shape[1], 2))
        self.stlimage[:,:,0] = segment_show
        self.stlimage[:,:,1] = segment_show
        self.showStlimage = np.copy(self.stlimage)
        self.to_stl(self.stlimage, filename="main")

        self.inputType = "2D Thinsection"

        #################################Save Data#############################
        self.project['type'] = self.inputType
        self.project['xdim'] = self.x
        self.project['ydim'] = self.y
        self.project['zdim'] = self.z
        self.project['resolution'] = self.resolution
        self.project['stlimage'] = self.stlimage
        self.project['savemimage'] = img
        self.project['mainimage'] = self.image
        #######################################################################

        self.nextNumberThinsection.emit(self.x, self.y)

    ## -- Get the 3D Gray image -- ##
    @Slot(str, str, str, str)
    def get3DImage(self, url, z, start, resolution):
        worker = Mythread_function_3(self.get3DImage_th, url, z, start, resolution)
        self.dataCollectionThread = DataCaptureThread(self.timer)
        self.dataCollectionThread.start()
        self.threadpool.start(worker)

    def get3DImage_th(self, url, z, start, resolution):
        self.onTimer = True
        self.z = int(z)
        starting = int(start)
        self.resolution = float(resolution)

        im_test = Image.open(url)

        b = im_test.mode
        if "RGB" in b:
            im_test = im_test.convert("L")
        elif "16" in b:
            ims = np.array(im_test.getdata()).reshape(im_test.size[::-1])
            im_test = (np.array(ims, np.float)-np.min(ims))*255.0 / np.max(ims)-np.min(ims)

        im_test = np.array(im_test, dtype=np.uint8)
        im_test = np.transpose(im_test, (1, 0))
        im_test = np.fliplr(im_test)
        self.x, self.y = np.shape(im_test)
        saveimage = np.zeros(shape=[self.y,self.x,self.z])
        self.image = np.zeros(shape=[self.x,self.y,self.z])
        stlimage = np.zeros(shape=[self.x,self.y,self.z])

        head, tail = os.path.split(url)
        self.b,c = os.path.splitext(tail)

        try:
            self.total = starting+self.z+self.z
            self.counter = starting+self.z

            for i in range(starting, starting+self.z):
                if (self.run):
                    self.progress(i-starting, self.total, self.total)
                    if i<=9:
                        img = Image.open(head+'/'+self.b[:int(len(self.b))-1]+str(i)+c)

                        b = img.mode
                        if "RGB" in b:
                            img = img.convert("L")
                        elif "16" in b:
                            ims = np.array(img.getdata()).reshape(img.size[::-1])
                            img = (np.array(ims, np.float)-np.min(ims))*255.0 / np.max(ims)-np.min(ims)

                    elif i>9 and i<=99:
                        try:
                            img = Image.open(head+'/'+self.b[:int(len(self.b))-2]+str(i)+c)
                        except:
                            img = Image.open(head+'/'+self.b[:int(len(self.b))-1]+str(i)+c)

                        b = img.mode
                        if "RGB" in b:
                            img = img.convert("L")
                        elif "16" in b:
                            ims = np.array(img.getdata()).reshape(img.size[::-1])
                            img = (np.array(ims, np.float)-np.min(ims))*255.0 / np.max(ims)-np.min(ims)
                    else:
                        try:
                            img = Image.open(head+'/'+self.b[:int(len(self.b))-3]+str(i)+c)
                        except:
                            img = Image.open(head+'/'+self.b[:int(len(self.b))-1]+str(i)+c)

                        b = img.mode
                        if "RGB" in b:
                            img = img.convert("L")
                        elif "16" in b:
                            ims = np.array(img.getdata()).reshape(img.size[::-1])
                            img = (np.array(ims, np.float)-np.min(ims))*255.0 / np.max(ims)-np.min(ims)

                    img = np.array(img, dtype=np.uint8)
                    saveimage[:,:,i-starting] = img
                    # Save image to localstorage
                    save_image = Image.fromarray(img)
                    if i-starting<=8:
                        save_image.save(self.offlineStoragePath + '/MImages/M000' + str(i-starting+1) + '.png')
                    elif i-starting>8 and i-starting<=98:
                        save_image.save(self.offlineStoragePath + '/MImages/M00' + str(i-starting+1) + '.png')
                    else:
                        save_image.save(self.offlineStoragePath + '/MImages/M0' + str(i-starting+1) + '.png')

                    img = np.transpose(img, (1, 0))
                    img = np.fliplr(img)
                    self.image[:,:,i-starting] = img
                    stlimage[:,:,self.z+starting-i-1] = img
                    self.image = np.array(self.image, dtype=np.uint8)
                    stlimage = np.array(stlimage, dtype=np.uint8)
                else:
                    self.run = True
                    self.onTimer = False
                    self.percent.emit(0)
                    self.next3DNumber.emit(0, 0, 0, False)
                    return
        except:
            msg = "The image number " + str(i) + " does not exist"
            self.run = True
            self.onTimer = False
            self.percent.emit(0)
            self.importImage.emit(msg)
            return

        self.inputType = "3D Gray"

        #For Qt3D display (in segmented format)
        self.stlimage = np.copy(stlimage)
        for k in range (self.z):
            if (self.run):
                self.progress(self.counter+k, self.total, self.total)
                threshold_k, self.stlimage[:,:,k] = segmentation.binarize_globalThreshold(stlimage[:,:,k], 'otsu')

            else:
                self.run = True
                self.onTimer = False
                self.percent.emit(0)
                self.next3DNumber.emit(0, 0, 0, False)
                return

        self.stopButton.emit()
        self.stlimage = np.array(self.stlimage, dtype=bool)
        self.stlimage = ~self.stlimage
        self.stlimage = self.stlimage * 255
        self.stlimage = np.array(self.stlimage, dtype=np.uint8)
        self.showStlimage = np.copy(self.stlimage)
        self.to_stl(self.stlimage, filename="main")
        #######################################################
        self.onTimer = False
        self.total = 0
        self.counter = 0

        #################################Save Data#############################
        self.project['type'] = self.inputType
        self.project['xdim'] = self.x
        self.project['ydim'] = self.y
        self.project['zdim'] = self.z
        self.project['resolution'] = self.resolution
        self.project['stlimage'] = self.stlimage
        self.project['savemimage'] = saveimage
        self.project['mainimage'] = self.image
        #######################################################################

        self.next3DNumber.emit(self.x, self.y, self.z, True)
        return


    ## -- Get the 3D Binary image -- ##
    @Slot(str, str, str, str)
    def get3DImageBinary(self, url, z, start, resolution):
        worker = Mythread_function_3(self.get3DImageBinary_th, url, z, start, resolution)
        self.dataCollectionThread = DataCaptureThread(self.timer)
        self.dataCollectionThread.start()
        self.threadpool.start(worker)

    def get3DImageBinary_th(self, url, z, start, resolution):
        self.onTimer = True
        self.z = int(z)
        starting = int(start)
        self.resolution = float(resolution)

        im_test = Image.open(url)

        b = im_test.mode
        if "RGB" in b:
            im_test = im_test.convert("L")
        elif "16" in b:
            ims = np.array(im_test.getdata()).reshape(im_test.size[::-1])
            im_test = (np.array(ims, np.float)-np.min(ims))*255.0 / np.max(ims)-np.min(ims)

        im_test = np.array(im_test, dtype=np.uint8)
        im_test = np.transpose(im_test, (1, 0))
        im_test = np.fliplr(im_test)
        self.x, self.y = np.shape(im_test)
        self.image = np.zeros(shape=[self.x,self.y,self.z])
        saveimage = np.zeros(shape=[self.y,self.x,self.z])
        self.stlimage = np.zeros(shape=[self.x,self.y,self.z])

        head, tail = os.path.split(url)
        self.b,c = os.path.splitext(tail)

        try:
            self.total = (starting+self.z)+2*self.z
            self.counter = starting+self.z

            for i in range(starting, starting+self.z):
                if self.run:
                    self.progress(i-starting, self.total, self.total)
                    if i<=9:
                        img = Image.open(head+'/'+self.b[:int(len(self.b))-1]+str(i)+c)

                        b = img.mode
                        if "RGB" in b:
                            img = img.convert("L")
                        elif "16" in b:
                            ims = np.array(img.getdata()).reshape(img.size[::-1])
                            img = (np.array(ims, np.float)-np.min(ims))*255.0 / np.max(ims)-np.min(ims)
                    elif i>9 and i<=99:
                        try:
                            img = Image.open(head+'/'+self.b[:int(len(self.b))-2]+str(i)+c)
                        except:
                            img = Image.open(head+'/'+self.b[:int(len(self.b))-1]+str(i)+c)


                        b = img.mode
                        if "RGB" in b:
                            img = img.convert("L")
                        elif "16" in b:
                            ims = np.array(img.getdata()).reshape(img.size[::-1])
                            img = (np.array(ims, np.float)-np.min(ims))*255.0 / np.max(ims)-np.min(ims)
                    else:
                        try:
                            img = Image.open(head+'/'+self.b[:int(len(self.b))-3]+str(i)+c)
                        except:
                            img = Image.open(head+'/'+self.b[:int(len(self.b))-1]+str(i)+c)

                        b = img.mode
                        if "RGB" in b:
                            img = img.convert("L")
                        elif "16" in b:
                            ims = np.array(img.getdata()).reshape(img.size[::-1])
                            img = (np.array(ims, np.float)-np.min(ims))*255.0 / np.max(ims)-np.min(ims)

                    img = np.array(img, dtype=np.uint8)
                    # Save image to localstorage
                    saveimage[:,:,i-starting] = np.copy(img)
                    save_image = Image.fromarray(img)
                    if i-starting<=8:
                        save_image.save(self.offlineStoragePath + '/MImages/M000' + str(i-starting+1) + '.png')
                    elif i-starting>8 and i-starting<=98:
                        save_image.save(self.offlineStoragePath + '/MImages/M00' + str(i-starting+1) + '.png')
                    else:
                        save_image.save(self.offlineStoragePath + '/MImages/M0' + str(i-starting+1) + '.png')
                    img = np.transpose(img, (1, 0))
                    img = np.fliplr(img)
                    self.image[:,:,self.z-i+starting-1] = img
                    self.stlimage[:,:,self.z-i+starting-1] = img
                else:
                    self.run = True
                    self.onTimer = False
                    self.percent.emit(0)
                    self.next3DNumberBinary.emit(0, 0, 0, 0, [], [], [], [], False)
                    return
        except:
            msg = "The image number " + str(i) + " does not exist"
            self.run = True
            self.onTimer = False
            self.percent.emit(0)
            self.importImage.emit(msg)
            return


        self.stlimage = np.array(self.stlimage, dtype=np.uint8)
        self.image = np.array(self.image, dtype=bool)
        self.image = ~self.image
        self.image = self.image * 255
        self.image = np.array(self.image, dtype=np.uint8)
        self.im_segment = np.copy(self.image)
        poro_im = np.array(self.image, dtype=np.uint8)
        pore = np.count_nonzero(poro_im==255)
        self.porosity = pore/(self.x*self.y*self.z)*100
        self.porosity = round(self.porosity,2)

        state, xdata, ydata = self.PSD_image(self.im_segment)
        if not state:
            self.run = True
            self.onTimer = False
            self.percent.emit(0)
            self.next3DNumberBinary.emit(0, 0, 0, 0, [], [], [], [], False)
            return
        xdata = [float(i) for i in xdata]
        ydata = [float(i) for i in ydata]

        state, Gxdata, Gydata = self.GSD_image(self.im_segment)
        if not state:
            self.run = True
            self.onTimer = False
            self.percent.emit(0)
            self.next3DNumberBinary.emit(0, 0, 0, 0, [], [], [], [], False)
            return
        Gxdata = [float(i) for i in Gxdata]
        Gydata = [float(i) for i in Gydata]

        self.stopButton.emit()
        self.inputType = "3D Binary"
        self.showStlimage = np.copy(self.stlimage)
        self.to_stl(self.stlimage, filename="main")

        #################################Save Data#############################
        self.project['type'] = self.inputType
        self.project['xdim'] = self.x
        self.project['ydim'] = self.y
        self.project['zdim'] = self.z
        self.project['resolution'] = self.resolution
        self.project['stlimage'] = self.stlimage
        self.project['savemimage'] = saveimage
        self.project['mainimage'] = self.image
        self.project['simage'] = self.im_segment
        self.project['psdimagex'] = xdata
        self.project['psdimagey'] = ydata
        self.project['gsdimagex'] = Gxdata
        self.project['gsdimagey'] = Gydata
        self.project['imageporosity'] = self.porosity
        #######################################################################

        self.next3DNumberBinary.emit(self.x, self.y, self.z, self.porosity, xdata, ydata, Gxdata, Gydata, True)

        self.onTimer = False
        self.counter = 0
        self.total = 0
        return

    @Slot()
    def changeBlackWhite(self):
        if self.inputType == "3D Binary":
            self.image = np.array(self.image, dtype=bool)
            self.image = ~self.image
            self.image = self.image * 255
            self.image = np.array(self.image, dtype=np.uint8)

            self.stlimage = np.array(self.stlimage, dtype=bool)
            self.stlimage = ~self.stlimage
            self.stlimage = self.stlimage * 255
            self.stlimage = np.array(self.stlimage, dtype=np.uint8)

            self.im_segment = np.array(self.im_segment, dtype=bool)
            self.im_segment = ~self.im_segment
            self.im_segment = self.im_segment * 255
            self.im_segment = np.array(self.im_segment, dtype=np.uint8)

            if self.change_state == "white":
                radius_p = self.radius_g

                radius_g = self.radius_p

                self.change_state = "black"
            elif self.change_state == "black":
                radius_p = self.radius_p

                radius_g = self.radius_g

                self.change_state = "white"

            ydata_p, xf = np.histogram(radius_p, bins = 20, density=True)
            xdata_p = [(xf[k] + xf[k+1])/2 for k in range(len(ydata_p))]
            xdata_p = list(xdata_p)

            ydata_g, xf = np.histogram(radius_g, bins = 20, density=True)
            xdata_g = [(xf[k] + xf[k+1])/2 for k in range(len(ydata_g))]
            xdata_g = list(xdata_g)

            poro_im = np.array(self.image)
            pore = np.count_nonzero(poro_im==255)
            self.porosity = pore/(self.x*self.y*self.z)*100
            self.porosity = round(self.porosity,2)
#            self.project['seg_porosity'] = self.porosity

#            self.im = np.copy(self.img)
#            im_original = np.copy(self.img)
#            self.project['show_image'] = self.im_show
#            self.project['original_images'] = im_original
#            self.project['3d_images'] = self.img_3d
#            self.project['X'] = self.x
#            self.project['Y'] = self.y
#            self.project['Z'] = self.z

        elif self.inputType == "2D Binary":
            self.image = np.array(self.image, dtype=bool)
            self.image = ~self.image
            self.image = self.image * 255
            self.image = np.array(self.image, dtype=np.uint8)

            self.stlimage = np.array(self.stlimage, dtype=bool)
            self.stlimage = ~self.stlimage
            self.stlimage = self.stlimage * 255
            self.stlimage = np.array(self.stlimage, dtype=np.uint8)

            self.im_segment = np.array(self.im_segment, dtype=bool)
            self.im_segment = ~self.im_segment
            self.im_segment = self.im_segment * 255
            self.im_segment = np.array(self.im_segment, dtype=np.uint8)

            if self.change_state == "white":
                radius_p = self.radius_g

                radius_g = self.radius_p

                self.change_state = "black"
            elif self.change_state == "black":
                radius_p = self.radius_p

                radius_g = self.radius_g

                self.change_state = "white"

            ydata_p, xf = np.histogram(radius_p, bins = 20, density=True)
            xdata_p = [(xf[k] + xf[k+1])/2 for k in range(len(ydata_p))]
            xdata_p = list(xdata_p)

            ydata_g, xf = np.histogram(radius_g, bins = 20, density=True)
            xdata_g = [(xf[k] + xf[k+1])/2 for k in range(len(ydata_g))]
            xdata_g = list(xdata_g)

            poro_im = np.array(self.image)
            pore = np.count_nonzero(poro_im==255)
            self.porosity = pore/(self.x*self.y)*100
            self.porosity = round(self.porosity,2)

#            im_original = np.copy(self.img)
#            self.project['show_image'] = self.im_show
#            self.project['original_images'] = im_original
#            self.project['X'] = self.x
#            self.project['Y'] = self.y
#            self.project['res'] = self.resolution

        saveimage = np.array(~self.image, dtype=bool)

        # Save image to localstorage
        if len(saveimage.shape)==3:
            num = saveimage.shape[2]
            is3D = True
            # saveimage2 is for openfile func
            saveimage2 = np.zeros((self.y, self.x, self.z))
        else:
            num = 1
            is3D = False
            # saveimage2 is for openfile func
            saveimage2 = np.zeros((self.y, self.x))

        for i in range(num):
            if is3D:
                save_img = np.transpose(saveimage[:,:,num-i-1], (1, 0))
                save_img = np.flipud(save_img)
                saveimage2[:,:,i] = np.copy(save_img) * 255
                save_img = Image.fromarray(save_img)
            else:
                save_img = np.transpose(saveimage, (1, 0))
                save_img = np.flipud(save_img)
                saveimage2 = np.copy(save_img)
                save_img = Image.fromarray(save_img)

            if i<=8:
                save_img.save(self.offlineStoragePath + '/MImages/M000' + str(i+1) + '.png')
            elif i>8 and i<=98:
                save_img.save(self.offlineStoragePath + '/MImages/M00' + str(i+1) + '.png')
            else:
                save_img.save(self.offlineStoragePath + '/MImages/M0' + str(i+1) + '.png')

        self.showStlimage = np.copy(self.stlimage)
        self.to_stl(self.stlimage, filename="main")

        xdata_p = [float(i) for i in xdata_p]
        ydata_p = [float(i) for i in ydata_p]

        xdata_g = [float(i) for i in xdata_g]
        ydata_g = [float(i) for i in ydata_g]

        #################################Save Data#############################
        self.project['stlimage'] = self.stlimage
        self.project['savemimage'] = saveimage2
        self.project['mainimage'] = self.image
        self.project['segmentimage'] = self.im_segment
        self.project['psdimagex'] = xdata_p
        self.project['psdimagey'] = ydata_p
        self.project['gsdimagex'] = xdata_g
        self.project['gsdimagey'] = ydata_g
        self.project['imageporosity'] = self.porosity
        self.project['radius_g'] = radius_p
        self.project['radius_g'] = radius_g
        #######################################################################

        self.changeBW.emit(self.porosity, xdata_p, ydata_p, xdata_g, ydata_g)

    @Slot()
    def changePoreMatrix(self):
        if "3D" in self.inputType:
            self.showStlimage = np.array(self.showStlimage, dtype=bool)
            self.showStlimage = ~self.showStlimage
            self.showStlimage = self.showStlimage * 255
            self.showStlimage = np.array(self.showStlimage, dtype=np.uint8)

        elif "2D" in self.inputType:

            self.showStlimage = np.array(self.showStlimage, dtype=bool)
            self.showStlimage = ~self.showStlimage
            self.showStlimage = self.showStlimage * 255
            self.showStlimage = np.array(self.showStlimage, dtype=np.uint8)

        if (self.stlrecons is not None):
            self.stlrecons = np.array(self.stlrecons, dtype=bool)
            self.stlrecons = ~self.stlrecons
            self.stlrecons = self.stlrecons * 255
            self.stlrecons = np.array(self.stlrecons, dtype=np.uint8)
            self.to_stl(self.stlrecons, filename="reconstruct")

        self.to_stl(self.showStlimage, filename="main")

        self.changePM.emit()


    ## -- Perform the Denoising -- ##
    @Slot(str, str)
    def denoise(self, method, var):
        worker = Mythread_function_1(self.den, method, var)
        self.dataCollectionThread = DataCaptureThread(self.timer)
        self.dataCollectionThread.start()
        self.threadpool.start(worker)

    def den(self, method, var):
        self.onTimer = True
        self.im_denoise = np.copy(self.image)
        if "3D" in self.inputType:
            num = self.im_denoise.shape[2]
            is3D = True
            # saveimage is for openfile func
            saveimage = np.zeros((self.y, self.x, self.z))
        else:
            num = 1
            is3D = False
            saveimage = np.zeros((self.y, self.x))

        if (method == "Gaussian"):
            if not is3D:
                self.im_denoise = ndim.gaussian_filter(self.im_denoise, sigma=eval(var))
            else:
                self.im_denoise = np.copy(self.im_denoise)
                for k in range (self.z):
                    if self.run:
                        self.progress(k, self.z, self.z)
                        self.im_denoise[:,:,k] = ndim.gaussian_filter(self.im_denoise[:,:,k], sigma=eval(var))

                    else:
                        self.run = True
                        self.onTimer = False
                        self.percent.emit(0)
                        self.denoiseImage.emit(0, False)
                        return
        elif (method == "Prewitt"):
            if not is3D:
                self.im_denoise = ndim.prewitt(self.im_denoise)
            else:
                self.im_denoise = np.copy(self.im_denoise)
                for k in range (self.z):
                    if self.run:
                        self.progress(k, self.z, self.z)
                        self.im_denoise[:,:,k] = ndim.prewitt(self.im_denoise[:,:,k])
                    else:
                        self.run = True
                        self.onTimer = False
                        self.percent.emit(0)
                        self.denoiseImage.emit(0, False)
                        return
        elif (method == "Sobel"):
            if not is3D:
                self.im_denoise = ndim.sobel(self.im_denoise)
            else:
                self.im_denoise = np.copy(self.im_denoise)
                for k in range (self.z):
                    if self.run:
                        self.progress(k, self.z, self.z)
                        self.im_denoise[:,:,k] = ndim.sobel(self.im_denoise[:,:,k])
                    else:
                        self.run = True
                        self.onTimer = False
                        self.percent.emit(0)
                        self.denoiseImage.emit(0, False)
                        return
        elif (method == "Laplace"):
            if not is3D:
                self.im_denoise = ndim.laplace(self.im_denoise)
            else:
                self.im_denoise = np.copy(self.im_denoise)
                for k in range (self.z):
                    if self.run:
                        self.progress(k, self.z, self.z)
                        self.im_denoise[:,:,k] = ndim.laplace(self.im_denoise[:,:,k])
                    else:
                        self.run = True
                        self.onTimer = False
                        self.percent.emit(0)
                        self.denoiseImage.emit(0, False)
                        return
        elif (method == "Gaussian-Laplace"):
            if not is3D:
                self.im_denoise = ndim.gaussian_laplace(self.im_denoise, sigma=eval(var))
            else:
                self.im_denoise = np.copy(self.im_denoise)
                for k in range (self.z):
                    if self.run:
                        self.progress(k, self.z, self.z)
                        self.im_denoise[:,:,k] = ndim.gaussian_laplace(self.im_denoise[:,:,k], sigma=eval(self.sigma))
                    else:
                        self.run = True
                        self.onTimer = False
                        self.percent.emit(0)
                        self.denoiseImage.emit(0, False)
                        return
        elif (method == "Minimum"):
            if not is3D:
                self.im_denoise = ndim.minimum_filter(self.im_denoise, size=eval(var))
            else:
                self.im_denoise = np.copy(self.im_denoise)
                for k in range (self.z):
                    if self.run:
                        self.progress(k, self.z, self.z)
                        self.im_denoise[:,:,k] = ndim.minimum_filter(self.im_denoise[:,:,k], size=eval(var))
                    else:
                        self.run = True
                        self.onTimer = False
                        self.percent.emit(0)
                        self.denoiseImage.emit(0, False)
                        return
        elif (method == "Maximum"):
            if not is3D:
                self.im_denoise = ndim.maximum_filter(self.im_denoise, size=eval(var))
            else:
                self.im_denoise = np.copy(self.im_denoise)
                for k in range (self.z):
                    if self.run:
                        self.progress(k, self.z, self.z)
                        self.im_denoise[:,:,k] = ndim.maximum_filter(self.im_denoise[:,:,k], size=eval(var))
                    else:
                        self.run = True
                        self.onTimer = False
                        self.percent.emit(0)
                        self.denoiseImage.emit(0, False)
                        return
        elif (method == "Median"):
            if not is3D:
                self.im_denoise = ndim.median_filter(self.im_denoise, size=eval(var))
            else:
                self.im_denoise = np.copy(self.im_denoise)
                for k in range (self.z):
                    if self.run:
                        self.progress(k, self.z, self.z)
                        self.im_denoise[:,:,k] = ndim.median_filter(self.im_denoise[:,:,k], size=eval(var))
                    else:
                        self.run = True
                        self.onTimer = False
                        self.percent.emit(0)
                        self.denoiseImage.emit(0, False)
                        return
        elif (method == "Rank"):
            if not is3D:
                self.im_denoise = ndim.rank_filter(self.im_denoise, rank=-1, size=eval(var))
            else:
                self.im_denoise = np.copy(self.im_denoise)
                for k in range (self.z):
                    if self.run:
                        self.progress(k, self.z, self.z)
                        self.im_denoise[:,:,k] = ndim.rank_filter(self.im_denoise[:,:,k], rank=-1, size=eval(var))
                    else:
                        self.run = True
                        self.onTimer = False
                        self.percent.emit(0)
                        self.denoiseImage.emit(0, False)
                        return


        self.im_denoise = np.array(self.im_denoise, dtype=np.uint8)
        # Save image to localstorage
        for i in range(num):
            if self.run:
                if is3D:
                    save_image = np.transpose(self.im_denoise[:,:,i], (1, 0))
                    save_image = np.flipud(save_image)
                    saveimage[:,:,i] = np.copy(save_image)
                    save_image = Image.fromarray(save_image)
                else:
                    save_image = np.transpose(self.im_denoise, (1, 0))
                    save_image = np.flipud(save_image)
                    saveimage = np.copy(save_image)
                    save_image = Image.fromarray(save_image)

                if i<=8:
                    save_image.save(self.offlineStoragePath + '/DImages/M000' + str(i+1) + '.png')
                elif i>8 and i<=98:
                    save_image.save(self.offlineStoragePath + '/DImages/M00' + str(i+1) + '.png')
                else:
                    save_image.save(self.offlineStoragePath + '/DImages/M0' + str(i+1) + '.png')
            else:
                self.run = True
                self.onTimer = False
                self.percent.emit(0)
                self.denoiseImage.emit(0, False)
                return

        self.onTimer = False

        #################################Save Data#############################
        self.project['denoisemethod'] = method
        self.project['savedimage'] = saveimage
        self.project['dimage'] = self.im_denoise
        self.project['denoiseParam'] = eval(var)
        #######################################################################

        self.denoiseImage.emit(var, True)

    ## -- Perform the filtering -- ##
    @Slot(str, str, str, str, str)
    def filter(self, method, var1, var2, var3, var4):
        worker = Mythread_function_2(self.fil, method, var1, var2, var3, var4)
        self.dataCollectionThread = DataCaptureThread(self.timer)
        self.dataCollectionThread.start()
        self.threadpool.start(worker)

    def fil(self, method, var1, var2, var3, var4):
        self.onTimer = True
        if type(self.im_denoise) == type(None):
            self.im_filter = np.copy(self.image)
        else:
            self.im_filter = np.copy(self.im_denoise)

        if "3D" in self.inputType:
            num = self.im_filter.shape[2]
            is3D = True
            # saveimage is for openfile func
            saveimage = np.zeros((self.y, self.x, self.z))
        else:
            num = 1
            is3D = False
            saveimage = np.zeros((self.y, self.x))

        if (method == "Bilateral"):
            var1 = eval(var1)
            var2 = eval(var2)
            var3 = eval(var3)
            if not is3D:
                self.im_filter = cv2.bilateralFilter(self.im_filter, var1, var2, var3)
            else:
                for k in range (self.z):
                    if self.run:
                        self.progress(k, self.z, self.z)
                        self.im_filter[:,:,k] = cv2.bilateralFilter(self.im_filter[:,:,k], var1, var2, var3)
                    else:
                        self.run = True
                        self.onTimer = False
                        self.percent.emit(0)
                        self.filterImage.emit(0, 0, 0, 0, False)
                        return
        elif (method == "Bilateral modified"):
            var1 = eval(var1)
            var2 = eval(var2)
            self.im_filter = np.asarray(self.im_filter, dtype=np.float32) / 255.0
            if not is3D:
                self.im_filter = np.array(self.im_filter, dtype=np.float32)
                self.im_filter = np.stack(filter_bilateral(self.im_filter, var1, var2))
                self.im_filter = self.im_filter * 255.0
            else:
                for k in range (self.z):
                    if self.run:
                        self.progress(k, self.z, self.z)
                        self.im_filter[:,:,k] = np.stack(filter_bilateral(self.im_filter[:,:,k], var1, var2))
                        self.im_filter[:,:,k] = self.im_filter[:,:,k] * 255.0
                    else:
                        self.run = True
                        self.onTimer = False
                        self.percent.emit(0)
                        self.filterImage.emit(0, 0, 0, 0, False)
                        return
        elif (method == "Averaging"):
            var1 = eval(var1)
            kernel = np.ones((var1, var1), np.float32) / 25
            if not is3D:
                self.im_filter = cv2.filter2D(self.im_filter, -1, kernel)
            else:
                for k in range (self.z):
                    if self.run:
                        self.progress(k, self.z, self.z)
                        self.im_filter[:,:,k] = cv2.filter2D(self.im_filter[:,:,k], -1, kernel)
                    else:
                        self.run = True
                        self.onTimer = False
                        self.percent.emit(0)
                        self.filterImage.emit(0, 0, 0, 0, False)
                        return
        elif (method == "Smoothing"):
            var1 = eval(var1)
            var2 = eval(var2)
            if not is3D:
                self.im_filter = cv2.blur(self.im_filter, (var1, var2))
            else:
                for k in range (self.z):
                    if self.run:
                        self.progress(k, self.z, self.z)
                        self.im_filter[:,:,k] = cv2.blur(self.im_filter[:,:,k], (var1, var2))
                    else:
                        self.run = True
                        self.onTimer = False
                        self.percent.emit(0)
                        self.filterImage.emit(0, 0, 0, 0, False)
                        return
        elif (method == "Gaussian"):
            var1 = eval(var1)
            var2 = eval(var2)
            var3 = eval(var3)
            var4 = eval(var4)

            if (var1 % 2 == 0):
                ksize1 = var1 + 1
            if (var2 % 2 == 0):
                ksize2 = var2 + 1

            if not is3D:
                self.im_filter = cv2.GaussianBlur(self.im_filter, (ksize1, ksize2), sigmaX=var3, sigmaY=var4)
            else:
                for k in range (self.z):
                    if self.run:
                        self.progress(k, self.z, self.z)
                        self.im_filter[:,:,k] = cv2.GaussianBlur(self.im_filter[:,:,k], (ksize1, ksize2), sigmaX=var3, sigmaY=var4)
                    else:
                        self.run = True
                        self.onTimer = False
                        self.percent.emit(0)
                        self.filterImage.emit(0, 0, 0, 0, False)
                        return
        elif (method == "Median"):
            var1 = eval(var1)
            if (var1 % 2 == 0):
                ksize = var1 + 1
            if not is3D:
                self.im_filter = cv2.medianBlur(self.im_filter, ksize)
            else:
                for k in range (self.z):
                    if self.run:
                        self.progress(k, self.z, self.z)
                        self.im_filter[:,:,k] = cv2.medianBlur(self.im_filter[:,:,k], ksize)
                    else:
                        self.run = True
                        self.onTimer = False
                        self.percent.emit(0)
                        self.filterImage.emit(0, 0, 0, 0, False)
                        return

        self.im_filter = np.array(self.im_filter, dtype=np.uint8)
        # Save image to localstorage
        for i in range(num):
            if self.run:
                if is3D:
                    save_image = np.transpose(self.im_filter[:,:,i], (1, 0))
                    save_image = np.flipud(save_image)
                    saveimage[:,:,i] = np.copy(save_image)
                    save_image = Image.fromarray(save_image)
                else:
                    save_image = np.transpose(self.im_filter, (1, 0))
                    save_image = np.flipud(save_image)
                    saveimage = np.copy(save_image)
                    save_image = Image.fromarray(save_image)

                if i<=8:
                    save_image.save(self.offlineStoragePath + '/FImages/M000' + str(i+1) + '.png')
                elif i>8 and i<=98:
                    save_image.save(self.offlineStoragePath + '/FImages/M00' + str(i+1) + '.png')
                else:
                    save_image.save(self.offlineStoragePath + '/FImages/M0' + str(i+1) + '.png')
            else:
                self.run = True
                self.onTimer = False
                self.percent.emit(0)
                self.filterImage.emit(0, 0, 0, 0, False)
                return


        self.onTimer = False

        #################################Save Data#############################
        self.project['filtermethod'] = method
        self.project['savefimage'] = saveimage
        self.project['fimage'] = self.im_filter
        self.project['filterParam1'] = var1
        self.project['filterParam2'] = var2
        self.project['filterParam3'] = var3
        self.project['filterParam4'] = var4
        #######################################################################

        self.filterImage.emit(var1 ,var2, var3, var4, True)


    ## -- Perform the segmentation -- ##
    @Slot(str)
    def segment(self, method):
        worker = Mythread_function_0(self.seg, method)
        self.dataCollectionThread = DataCaptureThread(self.timer)
        self.dataCollectionThread.start()
        self.threadpool.start(worker)

    def seg(self, method):
        self.onTimer = True
        if type(self.im_filter) == type(None):
            if type(self.im_denoise) == type(None):
                self.im_segment = np.copy(self.image)
            else:
                self.im_segment = np.copy(self.im_denoise)
        else:
            self.im_segment = np.array(self.im_filter)

        if "3D" in self.inputType:
            num = self.im_segment.shape[2]
            is3D = True
            saveimage = np.zeros((self.y, self.x, self.z))
        else:
            is3D = False
            num = 1
            saveimage = np.zeros((self.y, self.x))

        self.total = 3*self.z
        self.counter = self.z

        if (method == "Otsu"):
            if not is3D:
                th, self.im_segment = segmentation.binarize_globalThreshold(self.im_segment, 'otsu')
                self.im_segment = self.im_segment * 255
                th = round(th,2)
                pore = np.count_nonzero(self.im_segment==255)
                self.porosity = pore/(self.x*self.y*self.z)*100
                self.porosity = round(self.porosity,2)

            else:
                poro_sum = 0
                threshold_sum = 0
                img = np.copy(self.im_segment)
                for k in range (self.z):
                    if self.run:
                        self.progress(k, self.total, self.total)
                        threshold_k, self.im_segment[:,:,k] = segmentation.binarize_globalThreshold(self.im_segment[:,:,k], 'otsu')
                        self.im_segment[:,:,k] = self.im_segment[:,:,k] * 255
                        a=np.count_nonzero(self.im_segment[:,:,k]==255)
                        poro_k = a/self.im_segment[:,:,k].size*100
                        poro_sum = poro_sum + poro_k
                        threshold_sum = threshold_sum + threshold_k
                    else:
                        self.run = True
                        self.onTimer = False
                        self.percent.emit(0)
                        self.threshold.emit(0, 0, [], [], [], [], False)
                        return

                poro_im = np.array(self.im_segment)
                pore = np.count_nonzero(poro_im==255)
                th = threshold_sum/self.z
                self.porosity = poro_sum/self.z
                th = round(th,2)
                self.porosity = round(self.porosity,2)

        elif (method == "KI"):
            if not is3D:
                th, self.im_segment = segmentation.binarize_globalThreshold(self.im_segment, 'KI')
                self.im_segment = self.im_segment * 255
                th = round(th,2)
                pore = np.count_nonzero(self.im_segment==255)
                self.porosity = pore/(self.x*self.y*self.z)*100
                self.porosity = round(self.porosity,2)
            else:
                poro_sum = 0
                threshold_sum = 0
                for k in range (self.z):
                    if self.run:
                        self.progress(k, self.total, self.total)
                        threshold_k, self.im_segment[:,:,k] = segmentation.binarize_globalThreshold(self.im_segment[:,:,k], 'KI')
                        self.im_segment[:,:,k] = self.im_segment[:,:,k] * 255
                        a=np.count_nonzero(self.im_segment[:,:,k]==255)
                        poro_k = a/self.im_segment[:,:,k].size*100
                        poro_sum = poro_sum + poro_k
                        threshold_sum = threshold_sum + threshold_k
                    else:
                        self.run = True
                        self.onTimer = False
                        self.percent.emit(0)
                        self.threshold.emit(0, 0, [], [], [], [], False)
                        return

                poro_im = np.array(self.im_segment)
                pore = np.count_nonzero(poro_im==255)
                th = threshold_sum/self.z
                self.porosity = poro_sum/self.z
                th = round(th,2)
                self.porosity = round(self.porosity,2)
        elif (method == "Watershed"):
            if not is3D:
                th, self.im_segment, labels = segmentation.label_watershed(self.im_segment)
                self.im_segment = self.im_segment * 255
                th = round(th,2)
                pore = np.count_nonzero(self.im_segment==255)
                self.porosity = pore/(self.x*self.y*self.z)*100
                self.porosity = round(self.porosity,2)
            else:
                poro_sum = 0
                threshold_sum = 0
                for k in range (self.z):
                    if self.run:
                        self.progress(k, self.total, self.total)
                        threshold_k, self.im_segment[:,:,k], labels = segmentation.label_watershed(self.im_segment[:,:,k])
                        self.im_segment[:,:,k] = self.im_segment[:,:,k] * 255
                        a=np.count_nonzero(self.im_segment[:,:,k]==255)
                        poro_k = a/self.im_segment[:,:,k].size*100
                        poro_sum = poro_sum + poro_k
                        threshold_sum = threshold_sum + threshold_k
                    else:
                        self.run = True
                        self.onTimer = False
                        self.percent.emit(0)
                        self.threshold.emit(0, 0, [], [], [], [], False)
                        return

                poro_im = np.array(self.im_segment)
                pore = np.count_nonzero(poro_im==255)
                th = threshold_sum/self.z
                self.porosity = poro_sum/self.z
                th = round(th,2)
                self.porosity = round(self.porosity,2)
        elif (method == "K-means"):
            if not is3D:
                th, self.im_segment, labels = segmentation.binarize_kmeans(self.im_segment)
                self.im_segment = self.im_segment * 255
                th = round(th,2)
                pore = np.count_nonzero(self.im_segment==255)
                self.porosity = pore/(self.x*self.y*self.z)*100
                self.porosity = round(self.porosity,2)
            else:
                poro_sum = 0
                threshold_sum = 0
                for k in range (self.z):
                    if self.run:
                        self.progress(k, self.total, self.total)
                        threshold_k, self.im_segment[:,:,k], labels = segmentation.binarize_kmeans(self.im_segment[:,:,k])
                        self.im_segment[:,:,k] = self.im_segment[:,:,k] * 255
                        a=np.count_nonzero(self.im_segment[:,:,k]==255)
                        poro_k = a/self.im_segment[:,:,k].size*100
                        poro_sum = poro_sum + poro_k
                        threshold_sum = threshold_sum + threshold_k
                    else:
                        self.run = True
                        self.onTimer = False
                        self.percent.emit(0)
                        self.threshold.emit(0, 0, [], [], [], [], False)
                        return

                poro_im = np.array(self.im_segment)
                pore = np.count_nonzero(poro_im==255)
                th = threshold_sum/self.z
                self.porosity = poro_sum/self.z
                th = round(th,2)
                self.porosity = round(self.porosity,2)
        elif (method == "Yen"):
            if not is3D:
                th = sk.threshold_yen(self.im_segment)
                self.im_segment = np.copy(self.im_segment)
                for i in range (self.im_segment.shape[0]):
                    if self.run:
                        self.progress(i ,self.im_segment.shape[0], self.im_segment.shape[0])
                        for j in range (self.im_segment.shape[1]):
                            if self.im_segment[i][j] < th:
                                self.im_segment[i][j] = 255
                            else:
                                self.im_segment[i][j] = 0
                    else:
                        self.run = True
                        self.onTimer = False
                        self.percent.emit(0)
                        self.threshold.emit(0, 0, [], [], [], [], False)
                        return
                th = round(th,2)
                pore = np.count_nonzero(self.im_segment==255)
                self.porosity = pore/(self.x*self.y*self.z)*100
                self.porosity = round(self.porosity,2)
            else:
                poro_sum = 0
                threshold_sum = 0
                for k in range (self.z):
                    if self.run:
                        self.progress(k, self.total, self.total)
                        threshold_k = sk.threshold_yen(self.im_segment[:,:,k])

                        for i in range (self.x):
                            for j in range (self.y):
                                if self.im_segment[i][j][k] < threshold_k:
                                    self.im_segment[i][j][k] = 255
                                else:
                                    self.im_segment[i][j][k] = 0

                        a=np.count_nonzero(self.im_segment[:,:,k]==255)
                        poro_k = a/self.im_segment[:,:,k].size*100
                        poro_sum = poro_sum + poro_k
                        threshold_sum = threshold_sum + threshold_k
                    else:
                        self.run = True
                        self.onTimer = False
                        self.percent.emit(0)
                        self.threshold.emit(0, 0, [], [], [], [], False)
                        return

                poro_im = np.array(self.im_segment)
                pore = np.count_nonzero(poro_im==255)
                th = threshold_sum/self.z
                self.porosity = poro_sum/self.z
                th = round(th,2)
                self.porosity = round(self.porosity,2)
        elif (method == "Isodata"):
            if not is3D:
                th = sk.threshold_isodata(self.im_segment)
                self.im_segment = np.copy(self.im_segment)
                for i in range (self.im_segment.shape[0]):
                    if self.run:
                        self.progress(i ,self.im_segment.shape[0], self.im_segment.shape[0])
                        for j in range (self.im_segment.shape[1]):
                            if self.im_segment[i][j] < th:
                                self.im_segment[i][j] = 255
                            else:
                                self.im_segment[i][j] = 0
                    else:
                        self.run = True
                        self.onTimer = False
                        self.percent.emit(0)
                        self.threshold.emit(0, 0, [], [], [], [], False)
                        return
                th = round(th,2)
                pore = np.count_nonzero(self.im_segment==255)
                self.porosity = pore/(self.x*self.y*self.z)*100
                self.porosity = round(self.porosity,2)
            else:
                poro_sum = 0
                threshold_sum = 0
                for k in range (self.z):
                    if self.run:
                        self.progress(k, self.total, self.total)
                        threshold_k = sk.threshold_isodata(self.im_segment[:,:,k])

                        for i in range (self.x):
                            for j in range (self.y):
                                if self.im_segment[i][j][k] < threshold_k:
                                    self.im_segment[i][j][k] = 255
                                else:
                                    self.im_segment[i][j][k] = 0

                        a=np.count_nonzero(self.im_segment[:,:,k]==255)
                        poro_k = a/self.im_segment[:,:,k].size*100
                        poro_sum = poro_sum + poro_k
                        threshold_sum = threshold_sum + threshold_k
                    else:
                        self.run = True
                        self.onTimer = False
                        self.percent.emit(0)
                        self.threshold.emit(0, 0, [], [], [], [], False)
                        return

                poro_im = np.array(self.im_segment)
                pore = np.count_nonzero(poro_im==255)
                th = threshold_sum/self.z
                self.porosity = poro_sum/self.z
                th = round(th,2)
                self.porosity = round(self.porosity,2)
        elif (method == "Li"):
            if not is3D:
                th = sk.threshold_li(self.im_segment)
                self.im_segment = np.copy(self.im_segment)
                for i in range (self.im_segment.shape[0]):
                    if self.run:
                        self.progress(i ,self.im_segment.shape[0], self.im_segment.shape[0])
                        for j in range (self.im_segment.shape[1]):
                            if self.im_segment[i][j] < th:
                                self.im_segment[i][j] = 255
                            else:
                                self.im_segment[i][j] = 0
                    else:
                        self.run = True
                        self.onTimer = False
                        self.percent.emit(0)
                        self.threshold.emit(0, 0, [], [], [], [], False)
                        return
                th = round(th,2)
                pore = np.count_nonzero(self.im_segment==255)
                self.porosity = pore/(self.x*self.y*self.z)*100
                self.porosity = round(self.porosity,2)
            else:
                poro_sum = 0
                threshold_sum = 0
                for k in range (self.z):
                    if self.run:
                        self.progress(k, self.total, self.total)
                        threshold_k = sk.threshold_li(self.im_segment[:,:,k])

                        for i in range (self.x):
                            for j in range (self.y):
                                if self.im_segment[i][j][k] < threshold_k:
                                    self.im_segment[i][j][k] = 255
                                else:
                                    self.im_segment[i][j][k] = 0

                        a=np.count_nonzero(self.im_segment[:,:,k]==255)
                        poro_k = a/self.im_segment[:,:,k].size*100
                        poro_sum = poro_sum + poro_k
                        threshold_sum = threshold_sum + threshold_k
                    else:
                        self.run = True
                        self.onTimer = False
                        self.percent.emit(0)
                        self.threshold.emit(0, 0, [], [], [], [], False)
                        return

                poro_im = np.array(self.im_segment)
                pore = np.count_nonzero(poro_im==255)
                th = threshold_sum/self.z
                self.porosity = poro_sum/self.z
                th = round(th,2)
                self.porosity = round(self.porosity,2)
        elif (method == "Mean"):
            if not is3D:
                th = sk.threshold_mean(self.im_segment)
                self.im_segment = np.copy(self.im_segment)
                for i in range (self.im_segment.shape[0]):
                    if self.run:
                        self.progress(i ,self.im_segment.shape[0], self.im_segment.shape[0])
                        for j in range (self.im_segment.shape[1]):
                            if self.im_segment[i][j] < th:
                                self.im_segment[i][j] = 255
                            else:
                                self.im_segment[i][j] = 0
                    else:
                        self.run = True
                        self.onTimer = False
                        self.percent.emit(0)
                        self.threshold.emit(0, 0, [], [], [], [], False)
                        return
                th = round(th,2)
                pore = np.count_nonzero(self.im_segment==255)
                self.porosity = pore/(self.x*self.y*self.z)*100
                self.porosity = round(self.porosity,2)
            else:
                poro_sum = 0
                threshold_sum = 0
                for k in range (self.z):
                    if self.run:
                        self.progress(k, self.total, self.total)
                        threshold_k = sk.threshold_mean(self.im_segment[:,:,k])

                        for i in range (self.x):
                            for j in range (self.y):
                                if self.im_segment[i][j][k] < threshold_k:
                                    self.im_segment[i][j][k] = 255
                                else:
                                    self.im_segment[i][j][k] = 0
                    else:
                        self.run = True
                        self.onTimer = False
                        self.percent.emit(0)
                        self.threshold.emit(0, 0, [], [], [], [], False)
                        return

                    a=np.count_nonzero(self.im_segment[:,:,k]==255)
                    poro_k = a/self.im_segment[:,:,k].size*100
                    poro_sum = poro_sum + poro_k
                    threshold_sum = threshold_sum + threshold_k

                poro_im = np.array(self.im_segment)
                pore = np.count_nonzero(poro_im==255)
                th = threshold_sum/self.z
                self.porosity = poro_sum/self.z
                th = round(th,2)
                self.porosity = round(self.porosity,2)
        elif (method == "Triangle"):
            if not is3D:
                th = sk.threshold_triangle(self.im_segment)
                self.im_segment = np.copy(self.im_segment)
                for i in range (self.im_segment.shape[0]):
                    if self.run:
                        self.progress(i ,self.im_segment.shape[0], self.im_segment.shape[0])
                        for j in range (self.im_segment.shape[1]):
                            if self.im_segment[i][j] < th:
                                self.im_segment[i][j] = 255
                            else:
                                self.im_segment[i][j] = 0
                    else:
                        self.run = True
                        self.onTimer = False
                        self.percent.emit(0)
                        self.threshold.emit(0, 0, [], [], [], [], False)
                        return
                th = round(th,2)
                pore = np.count_nonzero(self.im_segment==255)
                self.porosity = pore/(self.x*self.y*self.z)*100
                self.porosity = round(self.porosity,2)
            else:
                poro_sum = 0
                threshold_sum = 0
                for k in range (self.z):
                    if self.run:
                        self.progress(k, self.total, self.total)
                        threshold_k = sk.threshold_triangle(self.im_segment[:,:,k])

                        for i in range (self.x):
                            for j in range (self.y):
                                if self.im_segment[i][j][k] < threshold_k:
                                    self.im_segment[i][j][k] = 255
                                else:
                                    self.im_segment[i][j][k] = 0
                    else:
                        self.run = True
                        self.onTimer = False
                        self.percent.emit(0)
                        self.threshold.emit(0, 0, [], [], [], [], False)
                        return

                    a=np.count_nonzero(self.im_segment[:,:,k]==255)
                    poro_k = a/self.im_segment[:,:,k].size*100
                    poro_sum = poro_sum + poro_k
                    threshold_sum = threshold_sum + threshold_k

                poro_im = np.array(self.im_segment)
                pore = np.count_nonzero(poro_im==255)
                th = threshold_sum/self.z
                self.porosity = poro_sum/self.z
                th = round(th,2)
                self.porosity = round(self.porosity,2)
        else:
            if not is3D:
                th = float(method)
                self.im_segment = self.im_segment < th
                self.im_segment = self.im_segment * 255
                pore = np.count_nonzero(self.im_segment==255)
                self.porosity = pore/(self.x*self.y*self.z)*100
                self.porosity = round(self.porosity,2)
            else:
                poro_sum = 0
                threshold_sum = 0
                for k in range (self.z):
                    if self.run:
                        self.progress(k, self.total, self.total)
                        threshold_k = float(method)
                        self.im_segment[:,:,k] = (self.im_segment[:,:,k] < threshold_k)
                        self.im_segment[:,:,k] = self.im_segment[:,:,k] * 255
                        a=np.count_nonzero(self.im_segment[:,:,k]==255)
                        poro_k = a/self.im_segment[:,:,k].size*100
                        poro_sum = poro_sum + poro_k
                        threshold_sum = threshold_sum + threshold_k
                    else:
                        self.run = True
                        self.onTimer = False
                        self.percent.emit(0)
                        self.threshold.emit(0, 0, [], [], [], [], False)
                        return

                poro_im = np.array(self.im_segment)
                pore = np.count_nonzero(poro_im==255)
                th = threshold_sum/self.z
                self.porosity = poro_sum/self.z
                th = round(th,2)
                self.porosity = round(self.porosity,2)

        # Save image to localstorage
        self.im_segment = np.array(self.im_segment, dtype=np.uint8)
        img = np.copy(self.im_segment)
        img2 = ~img
        for i in range(num):
            if self.run:
                if is3D:
                    save_image = np.transpose(img[:,:,i], (1, 0))
                    save_image = np.flipud(save_image)
                    save_image = np.array(save_image, dtype=bool)
                    save_image = ~save_image
                    save_image = save_image * 255
                    save_image = np.array(save_image, dtype=np.uint8)
                    save_image = Image.fromarray(save_image)
                    saveimage[:,:,i] = np.copy(save_image)
                    self.stlimage[:,:,i] = img2[:,:,num-i-1]
                    self.im_segment[:,:,i] = img[:,:,num-i-1]
                else:
                    save_image = np.transpose(self.im_segment, (1, 0))
                    save_image = np.flipud(save_image)
                    save_image = np.array(save_image, dtype=bool)
                    save_image = ~save_image
                    save_image = save_image * 255
                    save_image = np.array(save_image, dtype=np.uint8)
                    save_image = Image.fromarray(save_image)
                    saveimage = np.copy(save_image)

                if i<=8:
                    save_image.save(self.offlineStoragePath + '/SImages/M000' + str(i+1) + '.png')
                elif i>8 and i<=98:
                    save_image.save(self.offlineStoragePath + '/SImages/M00' + str(i+1) + '.png')
                else:
                    save_image.save(self.offlineStoragePath + '/SImages/M0' + str(i+1) + '.png')
            else:
                self.run = True
                self.onTimer = False
                self.percent.emit(0)
                self.threshold.emit(0, 0, [], [], [], [], False)
                return

        state, xdata, ydata = self.PSD_image(self.im_segment)
        if not state:
            self.run = True
            self.onTimer = False
            self.percent.emit(0)
            self.threshold.emit(0, 0, [], [], [], [], False)
            return
        xdata = [float(i) for i in xdata]
        ydata = [float(i) for i in ydata]

        state, Gxdata, Gydata = self.GSD_image(self.im_segment)
        if not state:
            self.run = True
            self.onTimer = False
            self.percent.emit(0)
            self.threshold.emit(0, 0, [], [], [], [], False)
            return
        Gxdata = [float(i) for i in Gxdata]
        Gydata = [float(i) for i in Gydata]

        self.showStlimage = np.copy(self.stlimage)
        #For Qt3D display
        if is3D:
            self.to_stl(self.stlimage, filename="main")
        else:
            # Attach dual self.segment images together to make a 3d image
            self.stlimage = np.zeros((img2.shape[0], img2.shape[1], 2))
            self.stlimage[:,:,0] = img2
            self.stlimage[:,:,1] = img2
            self.to_stl(self.stlimage, filename="main")

        self.onTimer = False
        self.total = 0
        self.counter = 0

        #################################Save Data#############################
        self.project['segmentmethod'] = method
        self.project['savesimage'] = saveimage
        self.project['simage'] = self.im_segment
        self.project['segmentParam'] = th
        self.project['imageporosity'] = self.porosity
        self.project['stlimage'] = self.stlimage
        self.project['psdimagex'] = xdata
        self.project['psdimagey'] = ydata
        self.project['gsdimagex'] = Gxdata
        self.project['gsdimagey'] = Gydata
        #######################################################################

        self.threshold.emit(th, self.porosity, xdata, ydata, Gxdata, Gydata, True)

    ## -- Perform the recostruction (Statistical) -- ##
    @Slot(str, str, str, str)
    def statistical(self, x, y, z, c):
        worker = Mythread_function_3(self.statis, x, y, z, c)
        self.dataCollectionThread = DataCaptureThread(self.timer)
        self.dataCollectionThread.start()
        self.threadpool.start(worker)

    def statis(self, x, y, z, c):
        self.onTimer = True
        self.xx = int(x)
        self.yy = int(y)
        self.zz = int(z)
        c = int(c)

        saveimage = np.zeros((self.xx, self.yy, self.zz))

        image = np.array(self.im_segment, dtype=np.uint8)
        retval, f = cv2.threshold(image, 127, 255, cv2.THRESH_BINARY)
        f = f/255
        M, N = f.shape

        phi_target = self.S2_r(f, 0)

        X = self.xx
        Y = self.yy
        Z = self.zz

        M, N = f.shape

        r = 0
        step = 5
        S2_x = []
        S2_y = []
        self.stopButton.emit()

        while r <= min(M/2, N/2):
            if self.run:
                S2_x.append(r)
                S2_y.append(self.S2_r(f, r))
                r += step
            else:
                self.run = True
                self.onTimer = False
                self.percent.emit(0)
                self.reconstructStatisticalImage.emit(0, [], [], False)
                return


        c = c + 1

        F_x = []
        F_y = []

        pp = -1
        for r in S2_x:
            if self.run:
                pp += 1
                self.progress(pp, len(S2_x), len(S2_x))
                F_x.append(r)
                F_y.append((S2_y[int(r/step)] - S2_y[0]**2)/(S2_y[0] - S2_y[0]**2))
            else:
                self.run = True
                self.onTimer = False
                self.percent.emit(0)
                self.reconstructStatisticalImage.emit(0, [], [], False)
                return

        F = np.zeros((c + 1, c + 1, c + 1))
        pp = -1
        for i, j, k in itertools.product(range(c + 1), repeat = 3):
            if self.run:
                pp += 1
                self.progress(pp, (c+1)**3, (c+1)**3)
                r = np.sqrt(i**2 + j**2 + k**2)
                r1 = math.floor(r/step) * step
                r2 = r1 + step
    #            try:
                interp_F = interp1d([r1, r2], [F_y[int(r1/step)], F_y[int(r2/step)]], kind = 'linear')
    #            except:
    #                message = ['Critical', 'Insert an appropriate cutoff distance', 250]
    #                self.terminate()
    #                im = []
    #                return im, message, False
                F[i, j, k] = interp_F(r)
            else:
                self.run = True
                self.onTimer = False
                self.percent.emit(0)
                self.reconstructStatisticalImage.emit(0, [], [], False)
                return

        N_uni1 = np.random.rand(X + c + 1, Y + c + 1, Z + c + 1)
        N_uni2 = np.random.rand(X + c + 1, Y + c + 1, Z + c + 1)

        N_BM = np.sqrt(-2*np.log(N_uni1))*np.cos(2*np.pi*N_uni2)
        N = np.interp(N_BM, (N_BM.min(), N_BM.max()), (0, 1))

        R = np.zeros((X, Y, Z))

        x_pre = 0

        ranges = [
            range(c + 1),
            range(c + 1),
            range(c + 1),
        ]

        self.starting = True
        worker3 = Mythread_function_thread(self.progress_thread)
        self.threadpool.start(worker3)

        for x in range(x_pre, X):
            if self.run:
                R[x] = [[R[x, y, z] + np.sum([N[x + i, y + j, z + k] * F[i, j, k] for i, j, k in itertools.product(*ranges)])
                  for z in range (Z)] for y in  range(Y)]

                if (x==x_pre):
                    self.payan = X+1
                self.i = x+1
                self.zaman = X
            else:
                self.run = True
                self.onTimer = False
                self.starting = False
                self.percent.emit(0)
                self.reconstructStatisticalImage.emit(0, [], [], False)
                return

        self.starting = False

        R_scaled = np.interp(R, (R.min(), R.max()), (0, 1))
        R_bin, t = self.binarize(R_scaled, phi_target, 0.5)

        R_smooth = skimage.filters.gaussian(R_bin, sigma = 1)
        R_smooth_scaled = np.interp(R_smooth, (R_smooth.min(), R_smooth.max()), (0, 1))
        R_smooth_bin, t = self.binarize(R_smooth_scaled, phi_target, 0.5)
        final_image = np.array(R_smooth_bin) + 255
        final_image[final_image==2*255] = 0

        poro_im = np.array(final_image)
        pore = np.count_nonzero(poro_im==255)
        self.porosity = pore/(self.x*self.y*self.zz)*100
        self.porosity = round(self.porosity,2)

        self.im_reconstruct = np.copy(final_image)
        self.im_reconstruct = np.array(self.im_reconstruct, dtype=np.uint8)
        # Save image to localstorage
        num = self.im_reconstruct.shape[2]
        save_image = np.array(self.im_reconstruct, dtype=bool)
        save_image = ~save_image
        save_image = save_image * 255
        save_image = np.array(save_image, dtype=np.uint8)
        for i in range(num):
            saveimage[:,:,i] = np.copy(save_image[:,:,i])
            saveRimage = Image.fromarray(save_image[:,:,i])

            if i<=8:
                saveRimage.save(self.offlineStoragePath + '/RImages/M000' + str(i+1) + '.png')
            elif i>8 and i<=98:
                saveRimage.save(self.offlineStoragePath + '/RImages/M00' + str(i+1) + '.png')
            else:
                saveRimage.save(self.offlineStoragePath + '/RImages/M0' + str(i+1) + '.png')

        #For Qt3D display
        self.stlrecons = np.zeros((self.yy, self.xx, self.zz))
        num = self.im_reconstruct.shape[2]
        img = np.copy(self.im_reconstruct)
        img2 = ~img
        for i in range(num):
            stlimg = np.transpose(img2[:,:,i], (1, 0))
            stlimg = np.fliplr(stlimg)
            self.stlrecons[:,:,num-i-1] = stlimg
            # self.im_reconstruct[:,:,num-i-1] = img[:,:,i]
        self.to_stl(self.stlrecons, filename="reconstruct")


        S2_x = [float(i) for i in S2_x]
        S2_y = [float(i) for i in S2_y]

        self.onTimer = False

        #################################Save Data#############################
        self.project['reconstructmethod'] = "Statistical"
        self.project['reconstructparam1'] = self.xx
        self.project['reconstructparam2'] = self.yy
        self.project['reconstructparam3'] = self.zz
        self.project['reconstructparam4'] = c
        self.project['saverimage'] = saveimage
        self.project['rimage'] = self.im_reconstruct
        self.project['reconstructporosity'] = self.porosity
        self.project['stlrecons'] = self.stlrecons
        self.project['s2imagex'] = S2_x
        self.project['s2imagey'] = S2_y
        #######################################################################

        self.reconstructStatisticalImage.emit(self.porosity, S2_x, S2_y, True)

    def S2_mn(self, f, m, n):
        if m < 0:
            m = 0
        if n < 0:
            n = 0
        M, N = f.shape

        m_1 = math.floor(m)
        n_1 = math.floor(n)
        m_2 = m_1 + 1
        n_2 = n_1 + 1

        S2_1 = 0
        S2_2 = 0
        S2_3 = 0
        S2_4 = 0

        i_max_1 = M - m_1
        i_max_2 = M - m_2
        j_max_1 = N - n_1
        j_max_2 = N - n_2

        S2_1 = [[S2_1 + f[i , j] * f[i + m_1, j + n_1] for j in range(j_max_1)] for i in range(i_max_1)]
        S2_1 = np.sum(S2_1)
        S2_1 /= i_max_1*j_max_1

        S2_2 = [[S2_2 + f[i , j] * f[i + m_1, j + n_2] for j in range(j_max_2)] for i in range(i_max_1)]
        S2_2 = np.sum(S2_2)
        S2_2 /= i_max_1*j_max_2

        S2_3 = [[S2_3 + f[i , j] * f[i + m_2, j + n_1] for j in range(j_max_1)] for i in range(i_max_2)]
        S2_3 = np.sum(S2_3)
        S2_3 /= i_max_2*j_max_1

        S2_4 = [[S2_4 + f[i , j] * f[i + m_2, j + n_2] for j in range(j_max_2)] for i in range(i_max_2)]
        S2_4 = np.sum(S2_4)
        S2_4 /= i_max_2*j_max_2
        interp_1 = interp1d([n_1, n_2], [S2_1, S2_2], kind='linear')
        interp_2 = interp1d([n_1, n_2], [S2_3, S2_4], kind='linear')
        S2_m_1 = interp_1(n)
        S2_m_2 = interp_2(n)
        interp_3 = interp1d([m_1, m_2], [S2_m_1, S2_m_2], kind='linear')
        S2 = interp_3(m)
        return S2

    def S2_r(self, f, r):
        S2 = 0
        if r == 0:
            S2 = self.S2_mn(f, 0, 0)
            return S2

        S2 = [S2 + self.S2_mn(f, r*math.cos(math.pi*l/4/r), r*math.sin(math.pi*l/4/r)) for l in range(math.floor(2*r) + 1)]
        S2 = np.sum(S2)
        S2 /= 2*r + 1
        return S2

    def binarize(self, R, phi_target, t, delta = 0.01, max_tries = 10000, max_err = 0.0001):
        M, N, P = R.shape
        for tries in range(max_tries):
            R_bin = np.where(R > t, 1, 0)
            phi = 1 - np.sum(R_bin)/M/N/P
            if abs(phi - phi_target) < max_err:
                return(R_bin, t)
            dR_bin = np.where(R > (t + delta), 1, 0)
            dphi = 1 - np.sum(dR_bin)/M/N/P
            t -= (phi - phi_target)/((dphi - phi)/delta)
        raise ValueError('no solution found')

    ## -- Perform the recostruction (MPS)-- ##
    @Slot(str, str, str, str, str, str)
    def mps(self, x, y, z, x_tem, y_tem, z_tem):
        worker = Mythread_function_4(self.mps_th, x, y, z, x_tem, y_tem, z_tem)
        self.dataCollectionThread = DataCaptureThread(self.timer)
        self.dataCollectionThread.start()
        self.threadpool.start(worker)

    def mps_th(self, x, y, z, x_tem, y_tem, z_tem):
        self.onTimer = True
        self.xx = int(x)
        self.yy = int(y)
        self.zz = int(z)
        x_tem = float(x_tem)
        y_tem = float(y_tem)
        z_tem = float(z_tem)

        saveimage = np.zeros((self.xx, self.yy, self.zz))

        max_img = np.amax(self.im_segment)
        a = np.where(self.im_segment==max_img)
        b = np.where(self.im_segment==0)
        self.im_segment[a] = 0
        self.im_segment[b] = max_img
        self.im_segment = self.im_segment/255
        mps.eas.write(self.im_segment, filename='image.dat', title=''+str(self.x)+' '+str(self.y)+' 1', header=['Header'])
        O = mps.mpslib(method='mps_snesim_tree', ti_fnam='image.dat',
                       verbose_level=-1, debug_level=-1)

        O.par['n_real'] = 1
        O.par['n_cond'] = 1000
        O.par['template_size'] = np.array([[x_tem,x_tem],[y_tem,y_tem],[1,1]])
        O.par['origin'] = np.array([0,0,0])
        O.par['simulation_grid_size'] = np.array([self.xx,self.yy,self.zz])

        ti = mps.eas.read('image.dat')
        O.ti = ti['Dmat']

        O.run()
        O.delete_gslib()

        final_image = O.sim

        im = np.zeros((self.xx,self.yy,self.zz))
        for i in range(self.zz):
            im[:,:,i] = final_image[0][:,:,i]

        im = ndim.zoom(im, zoom = [1,1,5], order=1)
        im = np.array(im, dtype=np.int8)
        im = ndim.median_filter(im, size=4)

        max_img = np.amax(im)
        a = np.where(im==max_img)
        b = np.where(im==0)
        im[a] = 0
        im[b] = max_img

        final_image = im[:,:,:self.zz]

        final_image = final_image * 255
        poro_im = np.array(final_image)
        pore = np.count_nonzero(poro_im==255)
        self.porosity = pore/(self.x*self.y*self.zz)*100
        self.porosity = round(self.porosity,2)

        self.im_reconstruct = np.copy(final_image)
        self.im_reconstruct = np.array(self.im_reconstruct, dtype=np.uint8)

        # Save image to localstorage
        num = self.im_reconstruct.shape[2]
        save_image = np.array(self.im_reconstruct, dtype=bool)
        save_image = ~save_image
        save_image = save_image * 255
        save_image = np.array(save_image, dtype=np.uint8)
        for i in range(num):
            saveimage[:,:,i] = np.copy(save_image[:,:,i])
            saveRimage = Image.fromarray(save_image[:,:,i])

            if i<=8:
                saveRimage.save(self.offlineStoragePath + '/RImages/M000' + str(i+1) + '.png')
            elif i>8 and i<=98:
                saveRimage.save(self.offlineStoragePath + '/RImages/M00' + str(i+1) + '.png')
            else:
                saveRimage.save(self.offlineStoragePath + '/RImages/M0' + str(i+1) + '.png')

        #For Qt3D display
        self.stlrecons = np.zeros((self.yy, self.xx, self.zz))
        num = self.im_reconstruct.shape[2]
        img = np.copy(self.im_reconstruct)
        img2 = ~img
        for i in range(num):
            stlimg = np.transpose(img2[:,:,i], (1, 0))
            stlimg = np.fliplr(stlimg)
            self.stlrecons[:,:,num-i-1] = stlimg
            # self.im_reconstruct[:,:,num-i-1] = img[:,:,i]
        self.to_stl(self.stlrecons, filename="reconstruct")

        self.onTimer = False

        #################################Save Data#############################
        self.project['reconstructmethod'] = "MPS"
        self.project['reconstructparam1'] = self.xx
        self.project['reconstructparam2'] = self.yy
        self.project['reconstructparam3'] = self.zz
        self.project['reconstructparam4'] = x_tem
        self.project['reconstructparam5'] = y_tem
        self.project['reconstructparam6'] = z_tem
        self.project['saverimage'] = saveimage
        self.project['rimage'] = self.im_reconstruct
        self.project['reconstructporosity'] = self.porosity
        self.project['stlrecons'] = self.stlrecons
        #######################################################################

        self.reconstructMPSImage.emit(self.porosity)

    ## -- Perform the construction -- ##
    @Slot(str, str, str, str, str, str, str, str, str, str)
    def construct(self, method, x, y, z, x_spa, y_spa, z_spa, connect, nump ,mode):
        worker = Mythread_function_5(self.construct_th, method, x, y, z, x_spa, y_spa, z_spa, connect, nump ,mode)
        self.dataCollectionThread = DataCaptureThread(self.timer)
        self.dataCollectionThread.start()
        self.threadpool.start(worker)

    def construct_th(self, method, x, y, z, x_spa, y_spa, z_spa, connect, nump , mode):

        self.onTimer = True
        self.network = None

        if method == 'Cubic':
            x_spa = eval(x_spa)
            y_spa = eval(y_spa)
            z_spa = eval(z_spa)
            connect = eval(connect)
            self.x = eval(x) * x_spa
            self.y = eval(y) * y_spa
            self.z = eval(z) * z_spa
            self.network = op.network.Cubic(shape=[eval(x),eval(y),eval(z)],
                                            spacing=[x_spa,y_spa,z_spa],
                                            connectivity=connect)

            pcoord, throatlen, tcenter, rotationAxis, angle = self.get3Dprops()

            self.message_Cubic.emit(True, self.x, self.y, self.z, pcoord,
                                    throatlen, tcenter, rotationAxis, angle)

        elif method == 'CubicDual':
            x_spa = eval(x_spa)
            self.x = eval(x) * x_spa
            self.y = eval(y) * x_spa
            self.z = eval(z) * x_spa
            self.network = op.network.CubicDual(shape=[eval(x),eval(y),eval(z)],
                                            spacing=x_spa)

            pcoord, throatlen, tcenter, rotationAxis, angle = self.get3Dprops()


            self.message_CubicDual.emit(True, self.x, self.y, self.z, pcoord,
                                    throatlen, tcenter, rotationAxis, angle)

        elif method == 'Bravais':
            x_spa = eval(x_spa)
            mode = str(mode)
            self.x = eval(x) * x_spa
            self.y = eval(y) * x_spa
            self.z = eval(z) * x_spa
            self.network = op.network.Bravais(shape=[eval(x),eval(y),eval(z)],
                                            spacing=x_spa,
                                            mode=mode)
            pcoord, throatlen, tcenter, rotationAxis, angle = self.get3Dprops()

            self.message_Bravais.emit(True, self.x, self.y, self.z, pcoord,
                                    throatlen, tcenter, rotationAxis, angle)

        elif method == 'DelaunayVoronoiDual':
            nump = eval(nump)
            self.x = eval(x) * 1e-6
            self.y = eval(y) * 1e-6
            self.z = eval(z) * 1e-6
            self.network = op.network.DelaunayVoronoiDual(shape=[eval(x),eval(y),eval(z)], num_points=nump)
            self.network['pore.coords'] *= 1e-6
            pcoord, throatlen, tcenter, rotationAxis, angle = self.get3Dprops()
            self.message_DelaunayVoronoiDual.emit(True, self.x, self.y, self.z, pcoord,
                                    throatlen, tcenter, rotationAxis, angle)

        elif method == 'Voronoi':
            nump = eval(nump)
            self.x = eval(x) * 1e-6
            self.y = eval(y) * 1e-6
            self.z = eval(z) * 1e-6
            self.network = op.network.Voronoi(shape=[eval(x),eval(y),eval(z)], num_points=nump)
            self.network['pore.coords'] *= 1e-6
            pcoord, throatlen, tcenter, rotationAxis, angle = self.get3Dprops()
            self.message_Voronoi.emit(True, self.x, self.y, self.z, pcoord,
                                    throatlen, tcenter, rotationAxis, angle)

        elif method == 'Delaunay':
            nump = eval(nump)
            self.x = eval(x) * 1e-6
            self.y = eval(y) * 1e-6
            self.z = eval(z) * 1e-6
            self.network = op.network.Delaunay(shape=[eval(x),eval(y),eval(z)], num_points=nump)
            self.network['pore.coords'] *= 1e-6
            pcoord, throatlen, tcenter, rotationAxis, angle = self.get3Dprops()
            self.message_Delaunay.emit(True, self.x, self.y, self.z, pcoord,
                                    throatlen, tcenter, rotationAxis, angle)

        elif method == 'Gabriel':
            nump = eval(nump)
            self.x = eval(x) * 1e-6
            self.y = eval(y) * 1e-6
            self.z = eval(z) * 1e-6
            self.network = op.network.Gabriel(shape=[eval(x),eval(y),eval(z)], num_points=nump)
            self.network['pore.coords'] *= 1e-6

            pcoord, throatlen, tcenter, rotationAxis, angle = self.get3Dprops()
            self.message_Gabriel.emit(True, self.x, self.y, self.z, pcoord,
                                    throatlen, tcenter, rotationAxis, angle)

        self.inputType = "Synthetic Network"

        #################################Save Data#############################
        self.project['type'] = self.inputType
        self.project['xdim'] = self.x
        self.project['ydim'] = self.y
        self.project['zdim'] = self.z
        self.project['constructmethod'] = method
        self.project['constructparam1'] = x_spa
        self.project['constructparam2'] = y_spa
        self.project['constructparam3'] = z_spa
        self.project['constructparam4'] = connect
        self.project['constructparam5'] = nump
        self.project['constructparam6'] = mode
        self.project['pcoord'] = pcoord
        self.project['throatlen'] = throatlen
        self.project['tcenter'] = tcenter
        self.project['rotationAxis'] = rotationAxis
        self.project['angle'] = angle
        #######################################################################

        self.getNetbackup = True
        self.getGeobackup = True

        self.onTimer = False

    def get3Dprops(self):
        from transforms3d import _gohlketransforms as tr

        porecoord = [list(i) for i in self.network['pore.coords']]
        pcoord = [[float(porecoord[i][j]) for j in range(3)] for i in range(len(porecoord))]

        cylinderVector = [0,-1,0]
        t_1 = [self.network['pore.coords'][self.network['throat.conns'][i]][0] for i in range(self.network.Nt)]
        t_2 = [self.network['pore.coords'][self.network['throat.conns'][i]][1] for i in range(self.network.Nt)]

        dist = [np.linalg.norm(t_1[i]-t_2[i]) for i in range(self.network.Nt)]

        throatlen = [float(i) for i in dist]

        tcenter_1 = [(self.network['pore.coords'][self.network['throat.conns'][i]][0] + \
                   self.network['pore.coords'][self.network['throat.conns'][i]][1])/2 for i in range(self.network.Nt)]

        throatcenter = [list(i) for i in tcenter_1]
        # throatcenter = [list(i) for i in self.geometry['throat.centroid']]
        tcenter = [[float(throatcenter[i][j]) for j in range(3)] for i in range(len(throatcenter))]

        conns = self.network['throat.conns']
        P1 = conns[:, 0]
        P2 = conns[:, 1]
        coords = self.network['pore.coords']
        vec = coords[P2] - coords[P1]
        unit_vec = tr.unit_vector(vec, axis=1)
        throats = self.network['throat.all']
        vectors = unit_vec[throats]

        rotation = [list(np.cross(i, cylinderVector)) for i in vectors]
        rotationAxis = [[float(rotation[i][j]) for j in range(3)] for i in range(len(rotation))]

        angle = [float(self.getAngle(i, cylinderVector, False)) for i in vectors]

        return pcoord, throatlen, tcenter, rotationAxis, angle

    ## -- Perform the extraction (SNOW)-- ##
    @Slot(str, str)
    def snow(self, r_max, sigma):
        worker = Mythread_function_1(self.snow_th, r_max, sigma)
        self.dataCollectionThread = DataCaptureThread(self.timer)
        self.dataCollectionThread.start()
        self.threadpool.start(worker)

    def snow_th(self, r_max, sigma):
        self.onTimer = True
        if self.inputType == "2D Gray":
            if type(self.im_segment) == type(None):
                print('First segment the image')
            elif type(self.im_reconstruct) == type(None):
                print('First reconstruct the image')
        elif self.inputType == "3D Gray":
            if type(self.im_segment) == type(None):
                print('First segment the image')
            else:
                self.im_reconstruct = np.copy(self.im_segment)
        elif self.inputType == "2D Binary" or self.inputType == "2D Thinsection":
            if type(self.im_reconstruct) == type(None):
                print('First reconstruct the image')
        else:
            self.im_reconstruct = np.copy(self.im_segment)

        r_max = float(r_max)
        sigma = float(sigma)

        regions = self.partitioning(im=self.im_reconstruct, r_max=r_max,
                                    sigma=sigma, return_all=True)
        im = regions.im
        dt = regions.dt
        regions = regions.regions
        b_num = np.amax(regions)

        boundary_faces=['top', 'bottom', 'left', 'right', 'front', 'back']
        voxel_size=self.resolution*1e-6
        regions = add_boundary_regions(regions=regions, faces=boundary_faces)

        dt = pad_faces(im=dt, faces=boundary_faces)
        im = pad_faces(im=im, faces=boundary_faces)
        regions = regions*im
        regions = make_contiguous(regions)

        net, state = self.regions_to_network(im=regions, dt=dt, voxel_size=voxel_size)
        if not state:
            self.run = True
            self.onTimer = False
            self.percent.emit(0)
            self.extractedSNOWNetwork.emit(0 , 0, False)
            return

        boundary_labels = net['pore.label'] > b_num
        loc1 = net['throat.conns'][:, 0] < b_num
        loc2 = net['throat.conns'][:, 1] >= b_num
        pore_labels = net['pore.label'] <= b_num
        loc3 = net['throat.conns'][:, 0] < b_num
        loc4 = net['throat.conns'][:, 1] < b_num
        net['pore.boundary'] = boundary_labels
        net['throat.boundary'] = loc1 * loc2
        net['pore.internal'] = pore_labels
        net['throat.internal'] = loc3 * loc4

        net = self.label_boundary_cells(network=net, boundary_faces=boundary_faces)

        pn = _net_dict(net)
        self.network = None
        self.network = op.network.GenericNetwork()
        self.network.update(pn)
        self.issnow = True

        self.getNetbackup = True
        self.getGeobackup = True

        self.onTimer = False

        #################################Save Data#############################
        self.project['extractionmethod'] = "SNOW"
        self.project['extractionparam1'] = r_max
        self.project['extractionparam2'] = sigma
        self.project['network'] = self.network
        #######################################################################

        self.extractedSNOWNetwork.emit(r_max , sigma, True)

    ## -- Perform the extraction (Maximal Ball)-- ##
    @Slot(str)
    def maximal(self, minR):
        worker = Mythread_function_0(self.maximal_th, minR)
        self.dataCollectionThread = DataCaptureThread(self.timer)
        self.dataCollectionThread.start()
        self.threadpool.start(worker)

    def maximal_th(self, minR):
        self.onTimer = True
        if self.inputType == "2D Gray":
            if type(self.im_segment) == type(None):
                print('First segment the image')
            elif type(self.im_reconstruct) == type(None):
                print('First reconstruct the image')
        elif self.inputType == "3D Gray":
            if type(self.im_segment) == type(None):
                print('First segment the image')
            else:
                self.im_reconstruct = np.copy(self.im_segment)
        elif self.inputType == "2D Binary" or self.inputType == "2D Thinsection":
            if type(self.im_reconstruct) == type(None):
                print('First reconstruct the image')
        else:
            self.im_reconstruct = np.copy(self.im_segment)

        minR = eval(minR)

        header = {}
        header['encoding'] = 'raw'
        nrrd.write('Image.raw', self.im_reconstruct ,header)

        foo = open("vxlImage.mhd", "w")
        foo.write('ObjectType =  Image\
                  \nNDims = 3\
                  \nElementType = MET_UCHAR\
                  \nDimSize =        '+str(self.x)+'  '+str(self.y)+'  '+str(self.z)+'\
                  \nElementSpacing = '+str(self.resolution*1e-6)+'  '+str(self.resolution*1e-6)+'   '+str(self.resolution*1e-6)+'\
                  \nOffset =         0   0   0\
                  \nElementByteOrderMSB = True\
                  \nElementDataFile = Image.raw\
                  \nminRPore='+str(minR)+'\
                  \nDefaultImageFormat = tif')

        foo.close()

        os.system('pnextract.exe')

        path=os.getcwd()
        stat=op.io.Statoil.load(path=path,prefix='Image')
        self.network = None
        self.network = stat.network
        self.network['pore.diameter'] = 2*self.network['pore.radius']
        self.network['throat.diameter'] = 2*self.network['throat.radius']
        self.ismb = True

        self.getNetbackup = True
        self.getGeobackup = True

        self.onTimer = False

        #################################Save Data#############################
        self.project['extractionmethod'] = "Maximal"
        self.project['extractionparam1'] = minR
        self.project['network'] = self.network
        #######################################################################

        self.extractedMaximalNetwork.emit(minR)

    def find_peaks(self, dt, r_max, footprint=None):
        im = dt > 0

        if footprint is None:
            if im.ndim == 2:
                footprint = disk
            elif im.ndim == 3:
                footprint = ball
            else:
                raise Exception("only 2-d and 3-d images are supported")
        mx = ndim.maximum_filter(dt + 2*(~im), footprint=footprint(r_max))
        peaks = (dt == mx)*im
        return peaks

    def trim_saddle_points(self, peaks, dt, max_iters=10):
        peaks = np.copy(peaks)

        labels, N = ndim.label(peaks)
        slices = ndim.find_objects(labels)
        for i in range(N):
            s = self.extend_slice(s=slices[i], shape=peaks.shape, pad=10)
            peaks_i = labels[s] == i+1
            dt_i = dt[s]
            im_i = dt_i > 0
            iters = 0
            peaks_dil = np.copy(peaks_i)
            while iters < max_iters:
                iters += 1
                peaks_dil = ndim.binary_dilation(input=peaks_dil,
                                                 structure=cube(3))
                peaks_max = peaks_dil*np.amax(dt_i*peaks_dil)
                peaks_extended = (peaks_max == dt_i)*im_i
                if np.all(peaks_extended == peaks_i):
                    break  # Found a true peak
                elif np.sum(peaks_extended*peaks_i) == 0:
                    peaks_i = False
                    break  # Found a saddle point
            peaks[s] = peaks_i
        return peaks

    def extend_slice(self, s, shape, pad=1):
        pad = int(pad)
        a = []
        for i, dim in zip(s, shape):
            start = 0
            stop = dim
            if i.start - pad >= 0:
                start = i.start - pad
            if i.stop + pad < dim:
                stop = i.stop + pad
            a.append(slice(start, stop, None))
        return tuple(a)

    def trim_nearby_peaks(self, peaks, dt):
        peaks = np.copy(peaks)
        if dt.ndim == 2:
            from skimage.morphology import square as cube
        else:
            from skimage.morphology import cube
        peaks, N = ndim.label(peaks, structure=cube(3))
        crds = ndim.measurements.center_of_mass(peaks, labels=peaks,
                                                index=np.arange(1, N+1))
        crds = np.vstack(crds).astype(int)  # Convert to numpy array of ints
        # Get distance between each peak as a distance map
        tree = sptl.cKDTree(data=crds)
        temp = tree.query(x=crds, k=2)
        nearest_neighbor = temp[1][:, 1]
        dist_to_neighbor = temp[0][:, 1]
        del temp, tree  # Free-up memory
        dist_to_solid = dt[tuple(crds.T)]  # Get distance to solid for each peak
        hits = np.where(dist_to_neighbor < dist_to_solid)[0]
        # Drop peak that is closer to the solid than it's neighbor
        drop_peaks = []
        for peak in hits:
            if dist_to_solid[peak] < dist_to_solid[nearest_neighbor[peak]]:
                drop_peaks.append(peak)
            else:
                drop_peaks.append(nearest_neighbor[peak])
        drop_peaks = np.unique(drop_peaks)
        # Remove peaks from image
        slices = ndim.find_objects(input=peaks)
        for s in drop_peaks:
            peaks[slices[s]] = 0
        return (peaks > 0)

    def randomize_colors(self, im, keep_vals=[0]):
        im_flat = im.flatten()
        keep_vals = np.array(keep_vals)
        swap_vals = ~np.in1d(im_flat, keep_vals)
        im_vals = np.unique(im_flat[swap_vals])
        new_vals = np.random.permutation(im_vals)
        im_map = np.zeros(shape=[np.amax(im_vals) + 1, ], dtype=int)
        im_map[im_vals] = new_vals
        im_new = im_map[im_flat]
        im_new = np.reshape(im_new, newshape=np.shape(im))
        return im_new

    def partitioning(self, im, r_max, sigma, dt=None, return_all=False,
                      mask=True, randomize=False):
        tup = namedtuple('results', field_names=['im', 'dt', 'peaks', 'regions'])
        im_shape = np.array(im.shape)
        if im.dtype is not bool:
            im = im > 0
        if dt is None:
            print('Peforming Distance Transform')
            if np.any(im_shape == 1):
                ax = np.where(im_shape == 1)[0][0]
                dt = ndim.distance_transform_edt(input=im.squeeze())
                dt = sp.expand_dims(dt, ax)
            else:
                dt = ndim.distance_transform_edt(input=im)

        tup.im = im
        tup.dt = dt

        if sigma > 0:
            print('Applying Gaussian blur with sigma =', str(sigma))
            dt = ndim.gaussian_filter(input=dt, sigma=sigma)

        peaks = self.find_peaks(dt=dt, r_max=r_max)
        peaks = self.trim_saddle_points(peaks=peaks, dt=dt, max_iters=500)
        peaks = self.trim_nearby_peaks(peaks=peaks, dt=dt)
        peaks, N = ndim.label(peaks)
        tup.peaks = peaks
        if mask:
            mask_solid = im > 0
        else:
            mask_solid = None
        regions = watershed(image=-dt, markers=peaks, mask=mask_solid)
        if randomize:
            regions = self.randomize_colors(regions)
        if return_all:
            tup.regions = regions
            return tup
        else:
            return regions

    def regions_to_network(self, im, dt=None, voxel_size=1):
        from skimage.morphology import disk, ball
        struc_elem = disk if im.ndim == 2 else ball

        if dt is None:
            dt = ndim.distance_transform_edt(im > 0)
            dt = ndim.gaussian_filter(input=dt, sigma=0.5)

        # Get 'slices' into im for each pore region
        slices = ndim.find_objects(im)

        # Initialize arrays
        Ps = np.arange(1, np.amax(im)+1)
        Np = np.size(Ps)
        p_coords = np.zeros((Np, im.ndim), dtype=float)
        p_volume = np.zeros((Np, ), dtype=float)
        p_dia_local = np.zeros((Np, ), dtype=float)
        p_dia_global = np.zeros((Np, ), dtype=float)
        p_label = np.zeros((Np, ), dtype=int)
        p_area_surf = np.zeros((Np, ), dtype=int)
        t_conns = []
        t_dia_inscribed = []
        t_area = []
        t_perimeter = []
        t_coords = []

        self.stopButton.emit()
        self.starting = True
        worker3 = Mythread_function_thread(self.progress_thread)
        self.threadpool.start(worker3)

        for i in Ps:
            if self.run:
                if (i==Ps[0]):
                    self.payan = len(Ps)+1
                self.i = i
                self.zaman = len(Ps)+1
                pore = i - 1
                if slices[pore] is None:
                    continue
                s = self.extend_slice(slices[pore], im.shape)
                sub_im = im[s]
                sub_dt = dt[s]
                pore_im = sub_im == i
                padded_mask = np.pad(pore_im, pad_width=1, mode='constant')
                pore_dt = ndim.distance_transform_edt(padded_mask)
                s_offset = np.array([i.start for i in s])
                p_label[pore] = i
                p_coords[pore, :] = ndim.center_of_mass(pore_im) + s_offset
                p_volume[pore] = np.sum(pore_im)
                p_dia_local[pore] = (2*np.amax(pore_dt)) - np.sqrt(3)
                p_dia_global[pore] = 2*np.amax(sub_dt)
                p_area_surf[pore] = np.sum(pore_dt == 1)
                im_w_throats = ndim.binary_dilation(input=pore_im, structure=struc_elem(1))
                im_w_throats = im_w_throats*sub_im
                Pn = np.unique(im_w_throats)[1:] - 1
                for j in Pn:
                    if j > pore:
                        t_conns.append([pore, j])
                        vx = np.where(im_w_throats == (j + 1))
                        t_dia_inscribed.append(2*np.amax(sub_dt[vx]))
                        t_perimeter.append(np.sum(sub_dt[vx] < 2))
                        t_area.append(np.size(vx[0]))
                        t_inds = tuple([i+j for i, j in zip(vx, s_offset)])
                        temp = np.where(dt[t_inds] == np.amax(dt[t_inds]))[0][0]
                        if im.ndim == 2:
                            t_coords.append(tuple((t_inds[0][temp],
                                                   t_inds[1][temp])))
                        else:
                            t_coords.append(tuple((t_inds[0][temp],
                                                   t_inds[1][temp],
                                                   t_inds[2][temp])))
            else:
                self.starting = False
                return {}, False

        self.starting = False

        # Clean up values
        Nt = len(t_dia_inscribed)  # Get number of throats
        if im.ndim == 2:  # If 2D, add 0's in 3rd dimension
            p_coords = np.vstack((p_coords.T, np.zeros((Np, )))).T
            t_coords = np.vstack((np.array(t_coords).T, np.zeros((Nt, )))).T

        net = {}
        net['pore.all'] = np.ones((Np, ), dtype=bool)
        net['throat.all'] = np.ones((Nt, ), dtype=bool)
        net['pore.coords'] = np.copy(p_coords)*voxel_size
        net['pore.centroid'] = np.copy(p_coords)*voxel_size
        net['throat.centroid'] = np.array(t_coords)*voxel_size
        net['throat.conns'] = np.array(t_conns)
        net['pore.label'] = np.array(p_label)
        net['pore.volume'] = np.copy(p_volume)*(voxel_size**3)
        net['throat.volume'] = np.zeros((Nt, ), dtype=float)
        net['pore.diameter'] = np.copy(p_dia_local)*voxel_size
        net['pore.inscribed_diameter'] = np.copy(p_dia_local)*voxel_size
        net['pore.equivalent_diameter'] = 2*((3/4*net['pore.volume']/np.pi)**(1/3))
        net['pore.extended_diameter'] = np.copy(p_dia_global)*voxel_size
        net['pore.diameter'] = net['pore.equivalent_diameter']
        net['pore.surface_area'] = np.copy(p_area_surf)*(voxel_size)**2
        net['throat.diameter'] = np.array(t_dia_inscribed)*voxel_size
        net['throat.inscribed_diameter'] = np.array(t_dia_inscribed)*voxel_size
        net['throat.area'] = np.array(t_area)*(voxel_size**2)
        net['throat.perimeter'] = np.array(t_perimeter)*voxel_size
        net['throat.equivalent_diameter'] = (np.array(t_area) * (voxel_size**2))**0.5
        net['throat.diameter'] = net['throat.equivalent_diameter']
        P12 = net['throat.conns']
        PT1 = np.sqrt(np.sum(((p_coords[P12[:, 0]]-t_coords) * voxel_size)**2, axis=1))
        PT2 = np.sqrt(np.sum(((p_coords[P12[:, 1]]-t_coords) * voxel_size)**2, axis=1))
        net['throat.total_length'] = PT1 + PT2
        PT1 = PT1-p_dia_local[P12[:, 0]]/2*voxel_size
        PT2 = PT2-p_dia_local[P12[:, 1]]/2*voxel_size
        net['throat.length'] = PT1 + PT2
        dist = (p_coords[P12[:, 0]]-p_coords[P12[:, 1]])*voxel_size
        net['throat.direct_length'] = np.sqrt(np.sum(dist**2, axis=1))
        if (self.inputType == "3D Gray" or self.inputType == "3D Binary"):
            net['throat.length'] = net['throat.total_length']
        # Make a dummy openpnm network to get the conduit lengths
        pn = op.network.GenericNetwork()
        pn.update(net)
        pn.add_model(propname='throat.endpoints',
                     model=op.models.geometry.throat_endpoints.spherical_pores,
                     pore_diameter='pore.inscribed_diameter',
                     throat_diameter='throat.inscribed_diameter')
        pn.add_model(propname='throat.conduit_lengths',
                     model=op.models.geometry.throat_length.conduit_lengths)
        pn.add_model(propname='pore.area',
                     model=op.models.geometry.pore_area.sphere)
        net['throat.endpoints.head'] = pn['throat.endpoints.head']
        net['throat.endpoints.tail'] = pn['throat.endpoints.tail']
        net['throat.conduit_lengths.pore1'] = pn['throat.conduit_lengths.pore1']
        net['throat.conduit_lengths.pore2'] = pn['throat.conduit_lengths.pore2']
        net['throat.conduit_lengths.throat'] = pn['throat.conduit_lengths.throat']
        net['pore.area'] = pn['pore.area']
        prj = pn.project
        prj.clear()
        wrk = op.Workspace()
        wrk.close_project(prj)

        return net, True

    def label_boundary_cells(self, network=None, boundary_faces=None):
        f = boundary_faces
        if f is not None:
            coords = network['pore.coords']
            condition = coords[~network['pore.boundary']]
            dic = {'left': 0, 'right': 0, 'front': 1, 'back': 1,
                   'top': 2, 'bottom': 2}
            if all(coords[:, 2] == 0):
                dic['top'] = 1
                dic['bottom'] = 1
            for i in f:
                if i in ['left', 'front', 'bottom']:
                    network['pore.{}'.format(i)] = (coords[:, dic[i]] <
                                                    min(condition[:, dic[i]]))
                elif i in ['right', 'back', 'top']:
                    network['pore.{}'.format(i)] = (coords[:, dic[i]] >
                                                    max(condition[:, dic[i]]))

        return network




#################################PSD Image################################################
    def PSD_image(self, img):
        im = np.copy(img)

        image = np.array(im, dtype=bool)

        radius = []
        radius = np.array(radius)

        if (len(im.shape)==3):
            for i in range(self.z):
                if (self.run):
                    self.progress(self.counter+i, self.total, self.total)
                    distance = ndim.distance_transform_edt(image[:,:,i])
                    local_maxi = peak_local_max(distance, indices=False, footprint=np.ones((10, 10)))
                    markers = ndim.label(local_maxi)[0]
                    B = watershed(-distance, markers, mask=image[:,:,i])

                    pore_n = np.amax(B)

                    V = []
                    for j in range(1, pore_n):
                        v = np.count_nonzero(B==j)
                        if v>1:
                            V.append(v)

                    r = [self.resolution * np.sqrt(v/np.pi) for v in V]
                    radius = np.concatenate((radius, r))
                else:
                    return False, [], []
            self.counter += self.z
        else:
            distance = ndim.distance_transform_edt(image)
            local_maxi = peak_local_max(distance, indices=False, footprint=np.ones((10, 10)))
            markers = ndim.label(local_maxi)[0]
            B = watershed(-distance, markers, mask=image)

            pore_n = np.amax(B)

            V = []
            for i in range(1, pore_n):
                v = np.count_nonzero(B==i)
                if v>1:
                    V.append(v)

            radius = [self.resolution * np.sqrt(v/np.pi) for v in V]

        self.project['radius_p'] = radius
        self.radius_p = radius

        ydata, xf = np.histogram(radius, bins = 20, density=True)
        xdata = [(xf[k] + xf[k+1])/2 for k in range(len(ydata))]
        xdata = list(xdata)

        return True, xdata, ydata

################################GSD Image################################################
    def GSD_image(self, img):
        im = np.copy(img)
        radius = []
        radius = np.array(radius)

        if (len(im.shape)==3):
            for i in range(self.z):
                if self.run:
                    self.progress(self.counter+i, self.total, self.total)
                    max_img = np.amax(im[:,:,i])
                    a = np.where(im[:,:,i]==max_img)
                    b = np.where(im[:,:,i]==0)
                    im[:,:,i][a] = 0
                    im[:,:,i][b] = max_img
                    image = np.array(im[:,:,i], dtype=bool)

                    distance = ndim.distance_transform_edt(image)
                    local_maxi = peak_local_max(distance, indices=False, footprint=np.ones((10, 10)))
                    markers = ndim.label(local_maxi)[0]
                    B = watershed(-distance, markers, mask=image)

                    grain_n = np.amax(B)

                    V = []
                    for j in range(1, grain_n):
                        v = np.count_nonzero(B==j)
                        if v>1:
                            V.append(v)

                    r = [self.resolution * np.sqrt(v/np.pi) for v in V]
                    radius = np.concatenate((radius, r))
                else:
                    return False, [], []
            self.counter += self.z
        else:
            max_img = np.amax(im)
            a = np.where(im==max_img)
            b = np.where(im==0)
            im[a] = 0
            im[b] = max_img
            image = np.array(im, dtype=bool)

            radius = []
            radius = np.array(radius)

            distance = ndim.distance_transform_edt(image)
            local_maxi = peak_local_max(distance, indices=False, footprint=np.ones((10, 10)))
            markers = ndim.label(local_maxi)[0]
            B = watershed(-distance, markers, mask=image)

            grain_n = np.amax(B)

            V = []
            for i in range(1, grain_n):
                v = np.count_nonzero(B==i)
                if v>1:
                    V.append(v)

            radius = [self.resolution * np.sqrt(v/np.pi) for v in V]

        self.project['radius_g'] = radius
        self.radius_g = radius

        ydata, xf = np.histogram(radius, bins = 20, density=True)
        xdata = [(xf[k] + xf[k+1])/2 for k in range(len(ydata))]
        xdata = list(xdata)

        return True, xdata, ydata

    @Slot()
    def endProcess(self):
        self.run = False

    def progress_thread(self):
        self.i = 0
        self.payan = 0
        self.zaman = 1
        while self.starting == True:
            time.sleep(0.1)
            if self.i!= self.payan-1:
                self.percent.emit(int(self.i*100/self.zaman))
            else:
                self.percent.emit(0)
        self.percent.emit(0)

    def progress(self, i, zaman, payan):
        if i!= payan-1:
            self.percent.emit(int(i*100/zaman))
        else:
            self.percent.emit(0)

    def timer(self):
        if (self.onTimer):
            if self.sec<60:
                self.print_time(self.mins, self.sec)
            else:
                self.mins += 1
                self.sec = 0
                self.print_time(self.mins, self.sec)

            self.sec += 1
            return True
        else:
            self.Timer_stop()
            return False

    def Timer_stop(self):
        self.sec = 0
        self.mins = 0
        mins = "00"
        sec = "00"
        self.time.emit(mins, sec)
        self.dataCollectionThread.terminate()

    def print_time(self, mins, sec):
        if sec<10:
            if mins<10:
                mins = "0" + str(mins)
                sec = "0" + str(sec)
            else:
                mins = str(mins)
                sec = "0" + str(sec)
        else:
            if mins<10:
                mins = "0" + str(mins)
                sec = str(sec)
            else:
                mins = str(mins)
                sec = str(sec)
        self.time.emit(mins, sec)


####################################################################################
    @Slot(str, str, str, str, str, str, str, str, str, str, str, str, str, str, str,
        str, str, str, str, str, str, str, str, str, str, str, str, str, str, str,
        str, str, str, str, str, str, str, str, str, str, str, str, str, str, str, str, str, str,
        str, str, str, str, str, str, str, str, str, str, str, str, str, str, str, str, str,
        str, str, str, str, str, str, str, str, str, str, str, str, str, str, str, str, str, str, str, str,
        str, str, str, str, str, str, str, str, str, str, str, str, str, str, str, str, str, str, str, str,
        str, str, str, str, str, str, str, str, str, str, str, str, str, str, str, str, bool, str, str, str,
        str, str, str, str, str, str, str, str, str, str, str)
    def simulation(self, porediam, poreseed, poresurf, porevol, porearea, throatdiam, throatseed,
                    throatsurf, throatvol, throatarea, throatendpoint, throatlength, throatperim, throatshape,
                    throatcentroid, throatvec, capillarypressure, diffusiveconductance, hydraulicconductance, multiphase, flowshape,
                    poissonshape, phase_inv, phase_def, den_inv, den_def, diff_inv, diff_def, elec_inv, elec_def,
                    mix_inv, mix_def, molar_inv, molar_def, partcoeff_inv, partcoeff_def, permittivity_inv,
                    permittivity_def, surf_inv, surf_def, vapor_inv, vapor_def, vis_inv, vis_def, concentration_inv,
                    concentration_def, pressure_inv, pressure_def, temp_inv, temp_def, moldiffvol_inv, moldiffvol_def,
                    volfrac_inv, volfrac_def, intcond_inv, intcond_def, molweight_inv, molweight_def, critemp_inv, critemp_def,
                    cripressure_inv, cripressure_def, crivol_inv, crivol_def, criangle_inv, criangle_def, poreshape, porescale, poreloc, poremode, poreweightx, poreweighty,
                    poreweightz, throatShape, throatscale, throatloc, throatmode, invadeMWA, invadeMWB, invadeatomicvolA,
                    invadeatomicvolB, invadediffcoeff, invademolvolA, invademolvolB, invadesurfA, invadesurfB, invadeperrelexp,
                    invadedickey, invadechemicalformula, invadeconstparam, invadeK2, invadeN, invadesurfprop, invadeprescoeffA,
                    invadeprescoeffB, invadeprescoeffC, invadeviscoeffA, invadeviscoeffB, defendMWA, defendMWB, defendatomicvolA,
                    defendatomicvolB, defenddiffcoeff, defendmolvolA, defendmolvolB, defendsurfA, defendsurfB, defendperrelexp,
                    defenddickey, defendchemicalformula, defendconstparam, defendK2, defendN, defendsurfprop, defendprescoeffA,
                    defendprescoeffB, defendprescoeffC, defendviscoeffA, defendviscoeffB, method, residual, trapping,
                    invadedensityU, invadediffusivityU, invadesalinityU, invademolardenU, invadesurfU, invadevaporU,
                    invadevisU, defenddensityU, defenddiffusivityU, defendsalinityU, defendmolardenU, defendsurfU, defendvaporU,
                    defendvisU):

        worker = Mythread_function_simulation(self.simulation_th, porediam, poreseed, poresurf, porevol, porearea, throatdiam, throatseed,
                                            throatsurf, throatvol, throatarea, throatendpoint, throatlength, throatperim, throatshape,
                                            throatcentroid, throatvec, capillarypressure, diffusiveconductance, hydraulicconductance, multiphase, flowshape,
                                            poissonshape, phase_inv, phase_def, den_inv, den_def, diff_inv, diff_def, elec_inv, elec_def,
                                            mix_inv, mix_def, molar_inv, molar_def, partcoeff_inv, partcoeff_def, permittivity_inv,
                                            permittivity_def, surf_inv, surf_def, vapor_inv, vapor_def, vis_inv, vis_def, concentration_inv,
                                            concentration_def, pressure_inv, pressure_def, temp_inv, temp_def, moldiffvol_inv, moldiffvol_def,
                                            volfrac_inv, volfrac_def, intcond_inv, intcond_def, molweight_inv, molweight_def, critemp_inv, critemp_def,
                                            cripressure_inv, cripressure_def, crivol_inv, crivol_def, criangle_inv, criangle_def, poreshape, porescale, poreloc, poremode, poreweightx, poreweighty,
                                            poreweightz, throatShape, throatscale, throatloc, throatmode, invadeMWA, invadeMWB, invadeatomicvolA,
                                            invadeatomicvolB, invadediffcoeff, invademolvolA, invademolvolB, invadesurfA, invadesurfB, invadeperrelexp,
                                            invadedickey, invadechemicalformula, invadeconstparam, invadeK2, invadeN, invadesurfprop, invadeprescoeffA,
                                            invadeprescoeffB, invadeprescoeffC, invadeviscoeffA, invadeviscoeffB, defendMWA, defendMWB, defendatomicvolA,
                                            defendatomicvolB, defenddiffcoeff, defendmolvolA, defendmolvolB, defendsurfA, defendsurfB, defendperrelexp,
                                            defenddickey, defendchemicalformula, defendconstparam, defendK2, defendN, defendsurfprop, defendprescoeffA,
                                            defendprescoeffB, defendprescoeffC, defendviscoeffA, defendviscoeffB, method, residual, trapping,
                                            invadedensityU, invadediffusivityU, invadesalinityU, invademolardenU, invadesurfU, invadevaporU,
                                            invadevisU, defenddensityU, defenddiffusivityU, defendsalinityU, defendmolardenU, defendsurfU, defendvaporU,
                                            defendvisU)
        self.dataCollectionThread = DataCaptureThread(self.timer)
        self.dataCollectionThread.start()
        self.threadpool.start(worker)

    def simulation_th(self, porediam, poreseed, poresurf, porevol, porearea, throatdiam, throatseed,
    throatsurf, throatvol, throatarea, throatendpoint, throatlength, throatperim, throatshape,
    throatcentroid, throatvec, capillarypressure, diffusiveconductance, hydraulicconductance, multiphase, flowshape,
    poissonshape, phase_inv, phase_def, den_inv, den_def, diff_inv, diff_def, elec_inv, elec_def,
    mix_inv, mix_def, molar_inv, molar_def, partcoeff_inv, partcoeff_def, permittivity_inv,
    permittivity_def, surf_inv, surf_def, vapor_inv, vapor_def, vis_inv, vis_def, concentration_inv,
    concentration_def, pressure_inv, pressure_def, temp_inv, temp_def, moldiffvol_inv, moldiffvol_def,
    volfrac_inv, volfrac_def, intcond_inv, intcond_def, molweight_inv, molweight_def, critemp_inv, critemp_def,
    cripressure_inv, cripressure_def, crivol_inv, crivol_def, criangle_inv, criangle_def, poreshape, porescale, poreloc, poremode, poreweightx, poreweighty,
    poreweightz, throatShape, throatscale, throatloc, throatmode, invadeMWA, invadeMWB, invadeatomicvolA,
    invadeatomicvolB, invadediffcoeff, invademolvolA, invademolvolB, invadesurfA, invadesurfB, invadeperrelexp,
    invadedickey, invadechemicalformula, invadeconstparam, invadeK2, invadeN, invadesurfprop, invadeprescoeffA,
    invadeprescoeffB, invadeprescoeffC, invadeviscoeffA, invadeviscoeffB, defendMWA, defendMWB, defendatomicvolA,
    defendatomicvolB, defenddiffcoeff, defendmolvolA, defendmolvolB, defendsurfA, defendsurfB, defendperrelexp,
    defenddickey, defendchemicalformula, defendconstparam, defendK2, defendN, defendsurfprop, defendprescoeffA,
    defendprescoeffB, defendprescoeffC, defendviscoeffA, defendviscoeffB, method, residual, trapping,
    invadedensityU, invadediffusivityU, invadesalinityU, invademolardenU, invadesurfU, invadevaporU,
    invadevisU, defenddensityU, defenddiffusivityU, defendsalinityU, defendmolardenU, defendsurfU, defendvaporU,
    defendvisU):
#        try:

        tt = 0
        self.progress(tt, 10, 10)
        self.onTimer = True
        h = self.network.check_network_health()
        isolated_pores = len(h['isolated_pores'])

        # net_prop = dict(self.network)
        # net_previous = op.network.GenericNetwork(name=''.join(random.choices(string.ascii_uppercase, k=15)))
        # net_previous.update(net_prop)
#        self.project['net_previous'] = net_previous

        if not self.run:
            self.run = True
            self.onTimer = False
            self.percent.emit(0)
            self.finalsimulation.emit(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, [], [], [], [],
                                      [], [], [], [], [], [], [], [], [], [], [], [], [], [],
                                      [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], False)
            return

        if not self.run:
            self.run = True
            self.onTimer = False
            self.percent.emit(0)
            self.finalsimulation.emit(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, [], [], [], [],
                                      [], [], [], [], [], [], [], [], [], [], [], [], [], [],
                                      [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], False)
            return

        if self.getGeobackup:
            self.geometry = None
            self.geometry = op.geometry.GenericGeometry(network=self.network,pores=self.network.Ps,throats=self.network.Ts,
                                                        name=''.join(random.choices(string.ascii_uppercase, k=15)))

        if not self.run:
            self.run = True
            self.onTimer = False
            self.percent.emit(0)
            self.finalsimulation.emit(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, [], [], [], [],
                                      [], [], [], [], [], [], [], [], [], [], [], [], [], [],
                                      [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], False)
            return

        tt += 1
        self.progress(tt, 10, 10)

        if (self.inputType == "Synthetic Network"):
            op.topotools.trim(network=self.network, pores=h['trim_pores'])


        if self.getNetbackup:
            net_prop = dict(self.network)
            net_previous = op.network.GenericNetwork(name=''.join(random.choices(string.ascii_uppercase, k=15)))
            net_previous.update(net_prop)
            self.backupNetwork = net_previous
            self.getNetbackup = False

        if poreseed != "":
            if poreseed == 'Random':
                self.geometry.add_model(propname='pore.seed',
                                    model = op.models.geometry.pore_seed.random)
            elif poreseed == 'Spatially_correlated':
                self.geometry.add_model(propname='pore.seed',
                                    model = op.models.geometry.pore_seed.spatially_correlated,
                                    weights = [eval(poreweightx), eval(poreweighty), eval(poreweightz)])

        if throatseed != "":
            if throatseed == 'Random':
                self.geometry.add_model(propname='throat.seed',
                                    model = op.models.geometry.throat_seed.random)
            elif throatseed == 'From_neighbor_pores':
                self.geometry.add_model(propname='throat.seed',
                                    model = op.models.geometry.throat_seed.from_neighbor_pores,
                                    pore_prop='pore.seed')

        if porediam != "":
            if porediam == 'Weibull':
                self.geometry.add_model(propname='pore.diameter',
                                    model = op.models.geometry.pore_size.weibull,
                                    shape = eval(poreshape) , scale= eval(porescale), loc=eval(poreloc))
            elif porediam == 'Normal':
                self.geometry.add_model(propname='pore.diameter',
                                    model = op.models.geometry.pore_size.random,
                                    scale= eval(porescale), loc=eval(poreloc))
            elif porediam == 'Random':
                self.geometry.add_model(propname='pore.diameter',
                                    model = op.models.geometry.pore_size.random)
            elif porediam == 'Generic-distribution':
                stats_obj = np.stats.weibull_min(c=2, scale=eval(porescale), loc=eval(poreloc))
                self.geometry.add_model(propname='pore.diameter',
                                    model = op.models.geometry.pore_size.generic_distribution,
                                    func=stats_obj)
            elif porediam == 'From-neighbor-throats':
                self.geometry.add_model(propname='pore.diameter',
                                    model = op.models.geometry.pore_size.from_neighbor_throats,
                                    throat_prop='throat.seed', mode = poremode)
                self.geometry['pore.diameter'] *= 1e-6
            # elif porediam == 'Equivalent_diameter':
            #     self.geometry.add_model(propname='pore.diameter',
            #                         model = op.models.geometry.pore_size.equivalent_diameter)

        if porevol:
            if porevol == 'Sphere':
                self.geometry.add_model(propname='pore.volume',
                                    model = op.models.geometry.pore_volume.sphere)
            elif porevol == 'Cube':
                self.geometry.add_model(propname='pore.volume',
                                    model = op.models.geometry.pore_volume.cube)
            elif porevol == 'Circle':
                self.geometry.add_model(propname='pore.area',
                                    model = op.models.geometry.pore_volume.circle)
            elif porevol == 'Square':
                self.geometry.add_model(propname='pore.volume',
                                    model = op.models.geometry.pore_volume.square)
            elif porevol == 'Cylinder':
                self.geometry.add_model(propname='pore.volume',
                                    model = op.models.geometry.pore_volume.cylinder)
        if porearea != "":
            if porearea == 'Sphere':
                self.geometry.add_model(propname='pore.area',
                                    model = op.models.geometry.pore_area.sphere)
            elif porearea == 'Cube':
                self.geometry.add_model(propname='pore.area',
                                    model = op.models.geometry.pore_area.cube)
            elif porearea == 'Circle':
                self.geometry.add_model(propname='pore.area',
                                    model = op.models.geometry.pore_area.circle)
            elif porearea == 'Square':
                self.geometry.add_model(propname='pore.area',
                                    model = op.models.geometry.pore_area.square)

        if not self.run:
            self.run = True
            self.onTimer = False
            self.percent.emit(0)
            self.finalsimulation.emit(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, [], [], [], [],
                                      [], [], [], [], [], [], [], [], [], [], [], [], [], [],
                                      [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], False)
            return

        if throatdiam != "":
            if throatdiam == 'Weibull':
                self.geometry.add_model(propname='throat.diameter',
                                    model = op.models.geometry.throat_size.weibull,
                                    shape=eval(throatShape), scale=eval(throatscale), loc=eval(throatloc))
            elif throatdiam == 'Normal':
                self.geometry.add_model(propname='throat.diameter',
                                    model = op.models.geometry.throat_size.normal,
                                    scale=eval(throatscale), loc=eval(throatloc))
            elif throatdiam == 'Generic_distribution':
                stats_obj = np.stats.weibull_min(c=2, scale=eval(throatscale), loc=eval(throatloc))
                self.geometry.add_model(propname='throat.diameter',
                                    model = op.models.geometry.throat_size.generic_distribution,
                                    func=stats_obj)
            elif throatdiam == 'Random':
                self.geometry.add_model(propname='throat.diameter',
                                    model = op.models.geometry.throat_size.random)
            elif throatdiam == 'From_neighbor_pores':
                self.geometry.add_model(propname='throat.diameter',
                                    model = op.models.geometry.throat_size.from_neighbor_pores,
                                    mode=throatmode)
            # elif throatdiam == 'Equivalent_diameter':
            #     stats_obj = np.stats.weibull_min(c=2, scale=eval(throatscale), loc=eval(throatloc))
            #     self.geometry.add_model(propname='throat.diameter',
            #                         model = op.models.geometry.throat_size.equivalent_diameter)


        if throatcentroid != "false" and 'throat.centroid' not in self.network and 'throat.centroid' not in self.geometry:
            self.geometry.add_model(propname='throat.centroid',
                                model = op.models.geometry.throat_centroid.pore_coords)
        if throatvec != "false" and 'throat.vector' not in self.network and 'throat.vector' not in self.geometry:
            self.geometry.add_model(propname='throat.vector',
                                model = op.models.geometry.throat_vector.pore_to_pore)

        if throatendpoint != "":
            if throatendpoint == 'Cubic_pores':
                self.geometry.add_model(propname='throat.endpoints',
                                    model = op.models.geometry.throat_endpoints.cubic_pores)
            elif throatendpoint == 'Square_pores':
                self.geometry.add_model(propname='throat.endpoints',
                                    model = op.models.geometry.throat_endpoints.square_pores)
            elif throatendpoint == 'Spherical_pores':
                self.geometry.add_model(propname='throat.endpoints',
                                    model = op.models.geometry.throat_endpoints.spherical_pores)
            elif throatendpoint == 'Circular_pores':
                self.geometry.add_model(propname='throat.endpoints',
                                    model = op.models.geometry.throat_endpoints.circular_pores)
            elif throatendpoint == 'Straight_throat':
                self.geometry.add_model(propname='throat.endpoints',
                                    model = op.models.geometry.throat_endpoints.straight_throat)

        if throatlength != "":
            if throatlength == 'ctc':
                self.geometry.add_model(propname='throat.length',
                                    model = op.models.geometry.throat_length.ctc)
            elif throatlength == 'Piecewise':
                self.geometry.add_model(propname='throat.length',
                                    model = op.models.geometry.throat_length.piecewise)
            elif throatlength == 'Classic':
                self.geometry.add_model(propname='throat.length',
                                    model = op.models.geometry.throat_length.classic)
            elif throatlength == 'Conduit_lengths':
                self.geometry.add_model(propname='throat.length',
                                    model = op.models.geometry.throat_length.piecewise)
            self.geometry.add_model(propname='throat.conduit_lengths',
                                    model = op.models.geometry.throat_length.conduit_lengths)

        if throatvol != "":
            if throatvol == 'Cylinder':
                self.geometry.add_model(propname='throat.volume',
                                    model = op.models.geometry.throat_volume.cylinder)
            elif throatvol == 'Cuboid':
                self.geometry.add_model(propname='throat.volume',
                                    model = op.models.geometry.throat_volume.cuboid)
            elif throatvol == 'Extrusion':
                self.geometry.add_model(propname='throat.volume',
                                    model = op.models.geometry.throat_volume.extrusion)
            elif throatvol == 'Rectangle':
                self.geometry.add_model(propname='throat.volume',
                                    model = op.models.geometry.throat_volume.rectangle)
            elif throatvol == 'Lens':
                self.geometry.add_model(propname='throat.volume',
                                    model = op.models.geometry.throat_volume.lens)
            elif throatvol == 'Pendular_ring':
                self.geometry.add_model(propname='throat.volume',
                                    model = op.models.geometry.throat_volume.pendular_ring)
        if throatarea != "":
            if throatarea == 'Cylinder':
                self.geometry.add_model(propname='throat.area',
                                    model = op.models.geometry.throat_area.cylinder)
            elif throatarea == 'Cuboid':
                self.geometry.add_model(propname='throat.area',
                                    model = op.models.geometry.throat_area.cuboid)
            elif throatarea == 'Rectangle':
                self.geometry.add_model(propname='throat.area',
                                    model = op.models.geometry.throat_area.rectangle)
        if poresurf != "":
            if poresurf == 'Sphere':
                self.geometry.add_model(propname='pore.surface_area',
                                    model = op.models.geometry.pore_surface_area.sphere)
            elif poresurf == 'Circle':
                self.geometry.add_model(propname='pore.surface_area',
                                    model = op.models.geometry.pore_surface_area.circle)
            elif poresurf == 'Cube':
                self.geometry.add_model(propname='pore.surface_area',
                                    model = op.models.geometry.pore_surface_area.cube)
            elif poresurf == 'Square':
                self.geometry.add_model(propname='pore.surface_area',
                                    model = op.models.geometry.pore_surface_area.square)

        if throatperim != "":
            if throatperim == 'Cylinder':
                self.geometry.add_model(propname='throat.perimeter',
                                    model = op.models.geometry.throat_perimeter.cylinder)
            elif throatperim == 'Cuboid':
                self.geometry.add_model(propname='throat.perimeter',
                                    model = op.models.geometry.throat_perimeter.cuboid)
            elif throatperim == 'Rectangle':
                self.geometry.add_model(propname='throat.perimeter',
                                    model = op.models.geometry.throat_perimeter.rectangle)

        if throatsurf:
            if throatsurf == 'Cylinder':
                self.geometry.add_model(propname='throat.surface_area',
                                    model = op.models.geometry.throat_surface_area.cylinder)
            elif throatsurf == 'Cuboid':
                self.geometry.add_model(propname='throat.surface_area',
                                    model = op.models.geometry.throat_surface_area.cuboid)
            elif throatsurf == 'Extrusion':
                self.geometry.add_model(propname='throat.surface_area',
                                    model = op.models.geometry.throat_surface_area.extrusion)
            elif throatsurf == 'Rectangle':
                self.geometry.add_model(propname='throat.surface_area',
                                    model = op.models.geometry.throat_surface_area.rectangle)

        if throatshape != "":
            if throatshape == 'Compactness':
                self.geometry.add_model(propname='throat.flow_shape_factors',
                                    model = op.models.geometry.throat_shape_factor.compactness)
            if throatshape == 'Mason_morrow':
                self.geometry.add_model(propname='throat.flow_shape_factors',
                                    model = op.models.geometry.throat_shape_factor.mason_morrow)
            if throatshape == 'Jenkins_rao':
                self.geometry.add_model(propname='throat.flow_shape_factors',
                                    model = op.models.geometry.throat_shape_factor.jenkins_rao)

        if not self.run:
            self.run = True
            self.onTimer = False
            self.percent.emit(0)
            self.finalsimulation.emit(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, [], [], [], [],
                                      [], [], [], [], [], [], [], [], [], [], [], [], [], [],
                                      [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], False)
            return

        if self.getGeobackup:
            geo_prop = dict(self.geometry)
            self.backupGeometry  = op.geometry.GenericGeometry(network=self.backupNetwork,pores=self.backupNetwork.Ps,throats=self.backupNetwork.Ts,
                                                               name=''.join(random.choices(string.ascii_uppercase, k=15)))
            self.backupGeometry.update(geo_prop)
            self.getGeobackup = False

        tt += 1
        self.progress(tt, 10, 10)

        radius = [float(i/2) for i in self.backupGeometry['pore.diameter']]
        porecoord = [list(i) for i in self.backupNetwork['pore.coords']]
        pcoord = [[float(porecoord[i][j]) for j in range(3)] for i in range(len(porecoord))]

        cylinderVector = [0,-1,0]
        throatradius = [float(i/2) for i in self.backupGeometry['throat.diameter']]

        t_1 = [self.backupGeometry['pore.coords'][self.backupGeometry['throat.conns'][i]][0] for i in range(self.backupNetwork.Nt)]
        t_2 = [self.backupGeometry['pore.coords'][self.backupGeometry['throat.conns'][i]][1] for i in range(self.backupNetwork.Nt)]

        dist = [np.linalg.norm(t_1[i]-t_2[i]) for i in range(self.backupNetwork.Nt)]

        throatlen = [float(i) for i in dist]

        tcenter_1 = [(self.backupGeometry['pore.coords'][self.backupGeometry['throat.conns'][i]][0] + \
                   self.backupGeometry['pore.coords'][self.backupGeometry['throat.conns'][i]][1])/2 for i in range(self.backupNetwork.Nt)]

        throatcenter = [list(i) for i in tcenter_1]
        # throatcenter = [list(i) for i in self.geometry['throat.centroid']]
        tcenter = [[float(throatcenter[i][j]) for j in range(3)] for i in range(len(throatcenter))]
        rotation = [list(np.cross(i, cylinderVector)) for i in self.backupGeometry['throat.vector']]
        rotationAxis = [[float(rotation[i][j]) for j in range(3)] for i in range(len(rotation))]

        angle = [float(self.getAngle(i, cylinderVector, False)) for i in self.backupGeometry['throat.vector']]
        if (self.inputType != "Synthetic Network"):
            op.topotools.trim(network=self.network, pores=h['trim_pores'])

        connected_pores = len(self.network['pore.all'])
        overal_pores = connected_pores + isolated_pores
        overal_throats = len(self.network['throat.all'])

        if self.ismb:
            op.topotools.label_faces(network=self.network)

        if self.inputType == "2D Binary" or self.inputType == "2D Gray" or \
        self.inputType == "2D Thinsection":
            if (isolated_pores/overal_pores)<0.65:
                op.topotools.label_faces(network=self.network)
        else:
            if np.count_nonzero(self.network['pore.left']==True)<2:
                 op.topotools.label_faces(network=self.network)
            elif np.count_nonzero(self.network['pore.right']==True)<2:
                op.topotools.label_faces(network=self.network)
            elif np.count_nonzero(self.network['pore.bottom']==True)<2:
                op.topotools.label_faces(network=self.network)
            elif np.count_nonzero(self.network['pore.top']==True)<2:
                op.topotools.label_faces(network=self.network)
            elif np.count_nonzero(self.network['pore.back']==True)<2:
                op.topotools.label_faces(network=self.network)
            elif np.count_nonzero(self.network['pore.front']==True)<2:
                op.topotools.label_faces(network=self.network)

        for i in self.network.props():
            if i not in ['throat.conns','pore.coords']:
                self.geometry.update({i:self.network.pop(i)})

##########################################################################################

        self.phase_inv = None
        if phase_inv == "Air":
            self.phase_inv = op.phases.Air(network = self.network)

        elif phase_inv == "Water":
            self.phase_inv = op.phases.Water(network = self.network)

        elif phase_inv == "Mercury":
            self.phase_inv = op.phases.Mercury(network = self.network)

        elif phase_inv == "User defined":
            self.phase_inv = op.phases.GenericPhase(network = self.network)

        if concentration_inv != '':
            self.phase_inv['pore.concentration'] = eval(concentration_inv)
        if temp_inv != '':
            self.phase_inv['pore.temperature'] = eval(temp_inv)
        if pressure_inv != '':
            self.phase_inv['pore.pressure'] = eval(pressure_inv)
        if criangle_inv != '':
            self.phase_inv['pore.contact_angle'] = eval(criangle_inv)

        if mix_inv != "":
            self.phase_inv['pore.molar_diffusion_volume'] = eval(moldiffvol_inv)
            self.phase_inv['pore.molecular_weight'] = eval(molweight_inv)

            if mix_inv == 'Salinity':
                self.phase_inv.add_model(propname='pore.salinity',
                                    model = op.models.phases.mixtures.salinity)
            elif mix_inv == 'Mole_weighted_average':
                self.phase_inv.add_model(model = op.models.phases.mixtures.mole_weighted_average,
                                        prop=eval(invadedickey))
            elif mix_inv == 'Fuller_diffusivity':
                self.phase_inv.add_model(propname='pore.diffusion_coeffient',
                                    model = op.models.phases.mixtures.fuller_diffusivity)
            elif mix_inv == 'Wilke_fuller_diffusivity':
                self.phase_inv.add_model(propname='pore.diffusion_coeffient',
                                    model = op.models.phases.mixtures.wilke_fuller_diffusivity)
            elif mix_inv == "User defined":
                self.phase_inv['pore.salinity'] = eval(invadesalinityU)

        if molar_inv != "":
            if molar_inv == 'Standard':
                self.phase_inv['pore.molecular_weight'] = eval(molweight_inv)
                self.phase_inv.add_model(propname='pore.molar_density',
                                    model = op.models.phases.molar_density.standard)
            elif molar_inv == 'Ideal_gas':
                self.phase_inv.add_model(propname='pore.molar_density',
                                    model = op.models.phases.molar_density.ideal_gas)
            elif molar_inv == 'Vanderwaals':
                self.phase_inv['pore.critical_pressure'] = eval(cripressure_inv)
                self.phase_inv['pore.critical_temperature'] = eval(critemp_inv)
                self.phase_inv.add_model(propname='pore.molar_density',
                                    model = op.models.phases.molar_density.vanderwaals)
            elif molar_inv == "User defined":
                self.phase_inv['pore.molar_density'] = eval(invademolardenU)

        if den_inv != "":
            if den_inv == 'Water':
                self.phase_inv.add_model(propname='pore.density',
                                    model = op.models.phases.density.water)
            elif den_inv == 'Standard':
                self.phase_inv['pore.molecular_weight'] = eval(molweight_inv)
                self.phase_inv.add_model(propname='pore.density',
                                    model = op.models.phases.density.standard)
            elif den_inv == 'Ideal_gas':
                self.phase_inv['pore.molecular_weight'] = eval(molweight_inv)
                self.phase_inv.add_model(propname='pore.density',
                                    model = op.models.phases.density.ideal_gas)
            elif den_inv == "User defined":
                self.phase_inv['pore.density'] = eval(invadedensityU)

        if vis_inv != "":
            if vis_inv == 'Water':
                self.phase_inv.add_model(propname='pore.viscosity',
                                    model = op.models.phases.viscosity.water)
            elif vis_inv == 'Reynolds':
                self.phase_inv.add_model(propname='pore.viscosity',
                                    model = op.models.phases.viscosity.reynolds,
                                    u0=eval(invadeviscoeffA), b=eval(invadeviscoeffB))
            elif vis_inv == 'Chung':
                self.phase_inv['pore.critical_temperature'] = eval(critemp_inv)
                self.phase_inv['pore.molecular_weight'] = eval(molweight_inv)
                self.phase_inv.add_model(propname='pore.viscosity',
                                    model = op.models.phases.viscosity.chung)
            elif vis_inv == "User defined":
                self.phase_inv['pore.viscosity'] = eval(invadevisU)

        if diff_inv != "":
            if diff_inv == 'Fuller':
                self.phase_inv.add_model(propname='pore.diffusivity',
                                    model = op.models.phases.diffusivity.fuller,
                                    MA=eval(invadeMWA), MB=eval(invadeMWB), vA=eval(invadeatomicvolA), vB=eval(invadeatomicvolB))
            elif diff_inv == 'Fuller_scaling':
                self.phase_inv.add_model(propname='pore.diffusivity',
                                    model = op.models.phases.diffusivity.fuller_scaling,
                                    DABo=eval(invadediffcoeff), Po=pressure_inv, To=temp_inv)
            elif diff_inv == 'Tyn_calus':
                self.phase_inv.add_model(propname='pore.diffusivity',
                                    model = op.models.phases.diffusivity.tyn_calus,
                                    VA=eval(invademolvolA), VB=eval(invademolvolB), sigmaA=eval(invadesurfA), sigmaB=eval(invadesurfB))
            elif diff_inv == 'Tyn_calus_scaling':
                self.phase_inv.add_model(propname='pore.diffusivity',
                                    model = op.models.phases.diffusivity.tyn_calus_scaling,
                                    DABo=eval(invadediffcoeff), To=temp_inv, mu_o=vis_inv)
            elif diff_inv == "User defined":
                self.phase_inv['pore.diffusivity'] = eval(invadediffusivityU)

        if elec_inv != "false":
            self.phase_inv['pore.volume_fraction'] = eval(volfrac_inv)
            self.phase_inv['pore.intrinsic_conductivity'] = eval(intcond_inv)
            self.phase_inv.add_model(propname='pore.electrical_conductivity',
                                model = op.models.phases.electrical_conductivity.percolating_continua,
                                phi_crit=volfrac_inv, tau=eval(invadeperrelexp))

        if partcoeff_inv != "false":
            self.phase_inv['throat.temperature'] = eval(temp_inv)
            self.phase_inv.add_model(propname='pore.partition_coefficient',
                                model = op.models.phases.partition_coefficient.gaseous_species_in_water,
                                chemical_formula =invadechemicalformula)

        if permittivity_inv != "false":
            self.phase_inv.add_model(propname='pore.permittivity',
                                model = op.models.phases.permittivity.water)

        if surf_inv != "":
            if surf_inv == 'Water':
                self.phase_inv.add_model(propname='pore.surface_tension',
                                    model = op.models.phases.surface_tension.water)
            elif surf_inv == 'Eotvos':
                self.phase_inv['pore.critical_temperature'] = eval(critemp_inv)
                self.phase_inv.add_model(propname='pore.surface_tension',
                                    model = op.models.phases.surface_tension.eotvos,
                                    k =eval(invadeconstparam))
            elif surf_inv == 'Guggenheim_katayama':
                self.phase_inv['pore.critical_pressure'] = eval(cripressure_inv)
                self.phase_inv['pore.critical_temperature'] = eval(critemp_inv)
                self.phase_inv.add_model(propname='pore.surface_tension',
                                    model = op.models.phases.surface_tension.guggenheim_katayama,
                                    K2=eval(invadeK2), n =eval(invadeN))
            elif surf_inv == 'Brock_bird_scaling':
                self.phase_inv['pore.critical_temperature'] = eval(critemp_inv)
                self.phase_inv.add_model(propname='pore.surface_tension',
                                    model = op.models.phases.surface_tension.brock_bird_scaling,
                                    sigma_o=eval(invadesurfprop), To=temp_inv)
            elif surf_inv == "User defined":
                self.phase_inv['pore.surface_tension'] = eval(invadesurfU)


        if vapor_inv != "":
            if vapor_inv == 'Water':
                self.phase_inv.add_model(propname='pore.vapor_pressure',
                                    model = op.models.phases.vapor_pressure.water)
            elif vapor_inv == 'Antoine':
                self.phase_inv.add_model(propname='pore.vapor_pressure',
                                    model = op.models.phases.vapor_pressure.antoine,
                                    A=eval(invadeprescoeffA), B=eval(invadeprescoeffB), C=eval(invadeprescoeffC))
            elif vapor_inv == "User defined":
                self.phase_inv['pore.vapor_pressure'] = eval(invadevaporU)

        if not self.run:
            self.run = True
            self.onTimer = False
            self.percent.emit(0)
            self.finalsimulation.emit(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, [], [], [], [],
                                      [], [], [], [], [], [], [], [], [], [], [], [], [], [],
                                      [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], False)
            return

        tt += 1
        self.progress(tt, 10, 10)
###################################################################################
        self.phase_def = None

        if phase_def == "Air":
            self.phase_def = op.phases.Air(network = self.network)
        elif phase_def == "Water":
            self.phase_def = op.phases.Water(network = self.network)
        elif phase_def == "Mercury":
            self.phase_def = op.phases.Mercury(network = self.network)
        elif phase_def == "User defined":
            self.phase_def = op.phases.GenericPhase(network = self.network)


        if concentration_def != '':
            self.phase_def['pore.concentration'] = eval(concentration_def)
        if temp_def != '':
            self.phase_def['pore.temperature'] = eval(temp_def)
        if pressure_def != '':
            self.phase_def['pore.pressure'] = eval(pressure_def)
        if criangle_def != '':
            self.phase_def['pore.contact_angle'] = eval(criangle_def)

        if mix_def != "":
            self.phase_def['pore.molar_diffusion_volume'] = eval(moldiffvol_def)
            self.phase_def['pore.molecular_weight'] = eval(molweight_def)

            if mix_def == 'Salinity':
                self.phase_def.add_model(propname='pore.salinity',
                                    model = op.models.phases.mixtures.salinity)
            elif mix_def == 'Mole_weighted_average':
                self.phase_def.add_model(model = op.models.phases.mixtures.mole_weighted_average,
                                        prop=eval(defenddickey))
            elif mix_def == 'Fuller_diffusivity':
                self.phase_def.add_model(propname='pore.diffusion_coeffient',
                                    model = op.models.phases.mixtures.fuller_diffusivity)
            elif mix_def == 'Wilke_fuller_diffusivity':
                self.phase_def.add_model(propname='pore.diffusion_coeffient',
                                    model = op.models.phases.mixtures.wilke_fuller_diffusivity)
            elif mix_def == "User defined":
                self.phase_def['pore.salinity'] = eval(defendsalinityU)

        if molar_def != "":
            if molar_def == 'Standard':
                self.phase_def['pore.molecular_weight'] = eval(molweight_def)
                self.phase_def.add_model(propname='pore.molar_density',
                                    model = op.models.phases.molar_density.standard)
            elif molar_def == 'Ideal_gas':
                self.phase_def.add_model(propname='pore.molar_density',
                                    model = op.models.phases.molar_density.ideal_gas)
            elif molar_def == 'Vanderwaals':
                self.phase_def['pore.critical_pressure'] = eval(cripressure_def)
                self.phase_def['pore.critical_temperature'] = eval(critemp_def)
                self.phase_def.add_model(propname='pore.molar_density',
                                    model = op.models.phases.molar_density.vanderwaals)
            elif molar_def == "User defined":
                self.phase_def['pore.molar_density'] = eval(defendmolardenU)

        if den_def != "":
            if den_def == 'Water':
                self.phase_def.add_model(propname='pore.density',
                                    model = op.models.phases.density.water)
            elif den_def == 'Standard':
                self.phase_def['pore.molecular_weight'] = eval(molweight_def)
                self.phase_def.add_model(propname='pore.density',
                                    model = op.models.phases.density.standard)
            elif den_def == 'Ideal_gas':
                self.phase_def['pore.molecular_weight'] = eval(molweight_def)
                self.phase_def.add_model(propname='pore.density',
                                    model = op.models.phases.density.ideal_gas)
            elif den_def == "User defined":
                self.phase_def['pore.density'] = eval(defenddensityU)

        if vis_def != "":
            if vis_def == 'Water':
                self.phase_def.add_model(propname='pore.viscosity',
                                    model = op.models.phases.viscosity.water)
            elif vis_def == 'Reynolds':
                self.phase_def.add_model(propname='pore.viscosity',
                                    model = op.models.phases.viscosity.reynolds,
                                    u0=eval(defendviscoeffA), b=eval(defendviscoeffB))
            elif vis_def == 'Chung':
                self.phase_def['pore.critical_temperature'] = eval(critemp_def)
                self.phase_def['pore.molecular_weight'] = eval(molweight_def)
                self.phase_def.add_model(propname='pore.viscosity',
                                    model = op.models.phases.viscosity.chung)
            elif vis_def == "User defined":
                self.phase_def['pore.viscosity'] = eval(defendvisU)

        if diff_def != "":
            if diff_def == 'Fuller':
                self.phase_def.add_model(propname='pore.diffusivity',
                                    model = op.models.phases.diffusivity.fuller,
                                    MA=eval(defendMWA), MB=eval(defendMWB), vA=eval(defendatomicvolA), vB=eval(defendatomicvolB))
            elif diff_def == 'Fuller_scaling':
                self.phase_def.add_model(propname='pore.diffusivity',
                                    model = op.models.phases.diffusivity.fuller_scaling,
                                    DABo=eval(defenddiffcoeff), Po=pressure_def, To=temp_def)
            elif diff_def == 'Tyn_calus':
                self.phase_def.add_model(propname='pore.diffusivity',
                                    model = op.models.phases.diffusivity.tyn_calus,
                                    VA=eval(defendmolvolA), VB=eval(defendmolvolB), sigmaA=eval(defendsurfA), sigmaB=eval(defendsurfB))
            elif diff_def == 'Tyn_calus_scaling':
                self.phase_def.add_model(propname='pore.diffusivity',
                                    model = op.models.phases.diffusivity.tyn_calus_scaling,
                                    DABo=eval(defenddiffcoeff), To=temp_def, mu_o=vis_def)
            elif diff_def == "User defined":
                self.phase_def['pore.diffusivity'] = eval(defenddiffusivityU)

        if elec_def != "false":
            self.phase_def['pore.volume_fraction'] = eval(volfrac_def)
            self.phase_def['pore.intrinsic_conductivity'] = eval(intcond_def)
            self.phase_def.add_model(propname='pore.electrical_conductivity',
                                model = op.models.phases.electrical_conductivity.percolating_continua,
                                phi_crit=volfrac_def, tau=eval(defendperrelexp))

        if partcoeff_def != "false":
            self.phase_def['throat.temperature'] = eval(temp_def)
            self.phase_def.add_model(propname='pore.partition_coefficient',
                                model = op.models.phases.partition_coefficient.gaseous_species_in_water,
                                chemical_formula =defendchemicalformula)

        if permittivity_def != "false":
            self.phase_def.add_model(propname='pore.permittivity',
                                model = op.models.phases.permittivity.water)

        if surf_def != "":
            if surf_def == 'Water':
                self.phase_def.add_model(propname='pore.surface_tension',
                                    model = op.models.phases.surface_tension.water)
            elif surf_def == 'Eotvos':
                self.phase_def['pore.critical_temperature'] = eval(critemp_def)
                self.phase_def.add_model(propname='pore.surface_tension',
                                    model = op.models.phases.surface_tension.eotvos,
                                    k =eval(defendconstparam))
            elif surf_def == 'Guggenheim_katayama':
                self.phase_def['pore.critical_pressure'] = eval(cripressure_def)
                self.phase_def['pore.critical_temperature'] = eval(critemp_def)
                self.phase_def.add_model(propname='pore.surface_tension',
                                    model = op.models.phases.surface_tension.guggenheim_katayama,
                                    K2=eval(defendK2), n =eval(defendN))
            elif surf_def == 'Brock_bird_scaling':
                self.phase_def['pore.critical_temperature'] = eval(critemp_def)
                self.phase_def.add_model(propname='pore.surface_tension',
                                    model = op.models.phases.surface_tension.brock_bird_scaling,
                                    sigma_o=eval(defendsurfprop), To=temp_def)
            elif surf_def == "User defined":
                self.phase_def['pore.surface_tension'] = eval(defendsurfU)

        if vapor_def != "":
            if vapor_def == 'Water':
                self.phase_def.add_model(propname='pore.vapor_pressure',
                                    model = op.models.phases.vapor_pressure.water)
            elif vapor_def == 'Antoine':
                self.phase_def.add_model(propname='pore.vapor_pressure',
                                    model = op.models.phases.vapor_pressure.antoine,
                                    A=eval(defendprescoeffA), B=eval(defendprescoeffB), C=eval(defendprescoeffC))
            elif vapor_def == "User defined":
                self.phase_def['pore.vapor_pressure'] = eval(defendvaporU)


        tt += 1
        self.progress(tt, 10, 10)

        if not self.run:
            self.run = True
            self.onTimer = False
            self.percent.emit(0)
            self.finalsimulation.emit(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, [], [], [], [],
                                      [], [], [], [], [], [], [], [], [], [], [], [], [], [],
                                      [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], False)
            return

#        ['phase_inv'] = self.phase_inv
#        self.project['phase_def'] = self.phase_def
###########################################################################################
        self.phys_inv = None
        self.phys_def = None

        self.phys_inv = op.physics.GenericPhysics(network=self.network, phase=self.phase_inv, geometry=self.geometry)
        self.phys_def = op.physics.GenericPhysics(network=self.network, phase=self.phase_def, geometry=self.geometry)

        if not self.run:
            self.run = True
            self.onTimer = False
            self.percent.emit(0)
            self.finalsimulation.emit(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, [], [], [], [],
                                      [], [], [], [], [], [], [], [], [], [], [], [], [], [],
                                      [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], False)
            return

        if capillarypressure != "":
            if capillarypressure == 'Washburn':
                self.phys_inv.add_model(propname='throat.entry_pressure',
                                        model = mods.capillary_pressure.washburn)
                self.phys_def.add_model(propname='throat.entry_pressure',
                                        model = mods.capillary_pressure.washburn)
            if capillarypressure == 'Purcell':
                self.phys_inv.add_model(propname='throat.entry_pressure',
                                        model = mods.capillary_pressure.purcell)
                self.phys_def.add_model(propname='throat.entry_pressure',
                                        model = mods.capillary_pressure.purcell)
            if capillarypressure == 'Purcell_bidirectional':
                self.phys_inv.add_model(propname='throat.entry_pressure',
                                        model = mods.capillary_pressure.purcell_bidirectional)
                self.phys_def.add_model(propname='throat.entry_pressure',
                                        model = mods.capillary_pressure.purcell_bidirectional)
            if capillarypressure == 'Ransohoff_snap_off':
                self.phys_inv.add_model(propname='throat.entry_pressure',
                                        model = mods.capillary_pressure.ransohoff_snap_off)
                self.phys_def.add_model(propname='throat.entry_pressure',
                                        model = mods.capillary_pressure.ransohoff_snap_off)
            if capillarypressure == 'Sinusoidal_bidirectional':
                self.phys_inv.add_model(propname='throat.entry_pressure',
                                        model = mods.capillary_pressure.sinusoidal_bidirectional)
                self.phys_def.add_model(propname='throat.entry_pressure',
                                        model = mods.capillary_pressure.sinusoidal_bidirectional)


        tt += 1
        self.progress(tt, 10, 10)

        if poissonshape != "":
            if poissonshape == 'Ball_and_stick':
                self.phys_inv.add_model(propname='throat.poisson_shape_factors',
                                        model = mods.poisson_shape_factors.ball_and_stick)
                self.phys_def.add_model(propname='throat.poisson_shape_factors',
                                        model = mods.poisson_shape_factors.ball_and_stick)
            elif poissonshape == 'Ball_and_stick_2D':
                self.phys_inv.add_model(propname='throat.poisson_shape_factors',
                                        model = mods.poisson_shape_factors.ball_and_stick_2D)
                self.phys_def.add_model(propname='throat.poisson_shape_factors',
                                        model = mods.poisson_shape_factors.ball_and_stick_2D)
            elif poissonshape == 'Conical_frustum_and_stick':
                self.phys_inv.add_model(propname='throat.poisson_shape_factors',
                                        model = mods.poisson_shape_factors.conical_frustum_and_stick)
                self.phys_def.add_model(propname='throat.poisson_shape_factors',
                                        model = mods.poisson_shape_factors.conical_frustum_and_stick)

        self.phase_inv['throat.diffusivity'] = 1e-9
        self.phase_def['throat.diffusivity'] = 1e-9

        if diffusiveconductance != "":
            if diffusiveconductance == 'Ordinary_diffusion':
                self.phys_inv.add_model(propname='throat.diffusive_conductance',
                                        model = mods.diffusive_conductance.ordinary_diffusion)
                self.phys_def.add_model(propname='throat.diffusive_conductance',
                                        model = mods.diffusive_conductance.ordinary_diffusion)
            elif diffusiveconductance == 'Ordinary_diffusion_2D':
                self.phys_inv.add_model(propname='throat.diffusive_conductance',
                                        model = mods.diffusive_conductance.ordinary_diffusion_2D)
                self.phys_def.add_model(propname='throat.diffusive_conductance',
                                        model = mods.diffusive_conductance.ordinary_diffusion_2D)
            elif diffusiveconductance == 'Mixed_diffusion':
                self.phys_inv.add_model(propname='throat.diffusive_conductance',
                                        model = mods.diffusive_conductance.mixed_diffusion)
                self.phys_def.add_model(propname='throat.diffusive_conductance',
                                        model = mods.diffusive_conductance.mixed_diffusion)
            elif diffusiveconductance == 'Taylor_aris_diffusion':
                self.phys_inv.add_model(propname='throat.diffusive_conductance',
                                        model = mods.diffusive_conductance.taylor_aris_diffusion)
                self.phys_def.add_model(propname='throat.diffusive_conductance',
                                        model = mods.diffusive_conductance.taylor_aris_diffusion)
            elif diffusiveconductance == 'Classic_ordinary_diffusion':
                self.phys_inv.add_model(propname='throat.diffusive_conductance',
                                        model = mods.diffusive_conductance.classic_ordinary_diffusion)
                self.phys_def.add_model(propname='throat.diffusive_conductance',
                                        model = mods.diffusive_conductance.classic_ordinary_diffusion)

        if hydraulicconductance != "":
            if hydraulicconductance == 'Hagen_poiseuille':
                self.phys_inv.add_model(propname='throat.hydraulic_conductance',
                                        model = mods.hydraulic_conductance.hagen_poiseuille)
                self.phys_def.add_model(propname='throat.hydraulic_conductance',
                                        model = mods.hydraulic_conductance.hagen_poiseuille)
            elif hydraulicconductance == 'Hagen_poiseuille_2D':
                self.phys_inv.add_model(propname='throat.hydraulic_conductance',
                                        model = mods.hydraulic_conductance.hagen_poiseuille_2D)
                self.phys_def.add_model(propname='throat.hydraulic_conductance',
                                        model = mods.hydraulic_conductance.hagen_poiseuille_2D)
            elif hydraulicconductance == 'Hagen_poiseuille_power_law':
                self.phys_inv.add_model(propname='throat.hydraulic_conductance',
                                        model = mods.hydraulic_conductance.hagen_poiseuille_power_law)
                self.phys_def.add_model(propname='throat.hydraulic_conductance',
                                        model = mods.hydraulic_conductance.hagen_poiseuille_power_law)
            elif hydraulicconductance == 'Valvatne_blunt':
                self.phys_inv.add_model(propname='throat.hydraulic_conductance',
                                        model = mods.hydraulic_conductance.valvatne_blunt)
                self.phys_def.add_model(propname='throat.hydraulic_conductance',
                                        model = mods.hydraulic_conductance.valvatne_blunt)

        if not self.run:
            self.run = True
            self.onTimer = False
            self.percent.emit(0)
            self.finalsimulation.emit(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, [], [], [], [],
                                      [], [], [], [], [], [], [], [], [], [], [], [], [], [],
                                      [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], False)
            return

        tt += 1
        self.progress(tt, 10, 10)

        if method != "Invasion Percolation":
            if multiphase != "":
                if multiphase == 'Conduit_conductance':
                    self.phys_inv.add_model(propname='throat.conduit_hydraulic_conductance',
                                            model = mods.multiphase.conduit_conductance,
                                            throat_conductance='throat.hydraulic_conductance')
                    self.phys_def.add_model(propname='throat.conduit_hydraulic_conductance',
                                            model = mods.multiphase.conduit_conductance,
                                            throat_conductance='throat.hydraulic_conductance')
                    self.phys_inv.add_model(propname='throat.conduit_diffusive_conductance',
                                            model = mods.multiphase.conduit_conductance,
                                            throat_conductance='throat.diffusive_conductance')
                    self.phys_def.add_model(propname='throat.conduit_diffusive_conductance',
                                            model = mods.multiphase.conduit_conductance,
                                            throat_conductance='throat.diffusive_conductance')
                elif multiphase == 'Late_filling':
                    self.phys_inv.add_model(propname='throat.conduit_hydraulic_conductance',
                                            model = mods.multiphase.late_filling)
                    self.phys_def.add_model(propname='throat.conduit_hydraulic_conductance',
                                            model = mods.multiphase.late_filling)
                    self.phys_inv.add_model(propname='throat.conduit_diffusive_conductance',
                                            model = mods.multiphase.late_filling)
                    self.phys_def.add_model(propname='throat.conduit_diffusive_conductance',
                                            model = mods.multiphase.late_filling)

        if flowshape != "":
            if flowshape == 'Ball_and_stick':
                self.phys_inv.add_model(propname='throat.shape_factor',
                                        model = mods.flow_shape_factors.ball_and_stick)
                self.phys_def.add_model(propname='throat.shape_factor',
                                        model = mods.flow_shape_factors.ball_and_stick)
            elif flowshape == 'Conical_frustum_and_stick':
                self.phys_inv.add_model(propname='throat.shape_factor',
                                        model = mods.flow_shape_factors.conical_frustum_and_stick)
                self.phys_def.add_model(propname='throat.shape_factor',
                                        model = mods.flow_shape_factors.conical_frustum_and_stick)
            elif flowshape == 'Ball_and_stick_2D':
                self.phys_inv.add_model(propname='throat.shape_factor',
                                        model = mods.flow_shape_factors.ball_and_stick_2D)
                self.phys_def.add_model(propname='throat.shape_factor',
                                        model = mods.flow_shape_factors.ball_and_stick_2D)

        self.phys_inv.regenerate_models()
        self.phys_def.regenerate_models()

        if not self.run:
            self.run = True
            self.onTimer = False
            self.percent.emit(0)
            self.finalsimulation.emit(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, [], [], [], [],
                                      [], [], [], [], [], [], [], [], [], [], [], [], [], [],
                                      [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], False)
            return

        tt += 1
        self.progress(tt, 10, 10)

#        self.project['phys_inv'] = self.phys_inv
#        self.project['phys_def'] = self.phys_def

        if self.inputType == "3D Binary" or self.inputType == "3D Gray":
            Lx = self.x*self.resolution*1e-6
            Ly = self.y*self.resolution*1e-6
            Lz = self.z*self.resolution*1e-6
        else:
            Lx = np.amax(self.network['pore.coords'][:, 0]) - np.amin(self.network['pore.coords'][:, 0])
            Ly = np.amax(self.network['pore.coords'][:, 1]) - np.amin(self.network['pore.coords'][:, 1])
            Lz = np.amax(self.network['pore.coords'][:, 2]) - np.amin(self.network['pore.coords'][:, 2])

        if self.inputType == "Synthetic Network":
            pnVolume= np.sum(self.geometry['pore.volume']) + np.sum(self.geometry['throat.volume'])
            self.porosity=((pnVolume)/(Lx*Ly*Lz))*100

        SF=op.algorithms.StokesFlow(network=self.network,phase=self.phase_inv)
        SF.set_value_BC(pores=self.network.pores('back'),values=200000)
        SF.set_value_BC(pores=self.network.pores('front'),values=100000)
        SF.run()
        Q_tot_x=np.absolute(SF.rate(pores=self.network.pores('back')))
        A_x=Lz*Ly

        DF=op.algorithms.FickianDiffusion(network=self.network,phase=self.phase_inv)
        DF.set_value_BC(pores=self.network.pores('back'),values=200000)
        DF.set_value_BC(pores=self.network.pores('front'),values=100000)
        DF.run()
        D1 = DF.rate(pores=self.network.pores('back'))[0]

        SF1=op.algorithms.StokesFlow(network=self.network,phase=self.phase_inv)
        SF1.set_value_BC(pores=self.network.pores('left'),values=200000)
        SF1.set_value_BC(pores=self.network.pores('right'),values=100000)
        SF1.run()
        Q_tot_y=np.absolute(SF1.rate(pores=self.network.pores('left')))
        A_y=Lx*Lz

        if not self.run:
            self.run = True
            self.onTimer = False
            self.percent.emit(0)
            self.finalsimulation.emit(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, [], [], [], [],
                                      [], [], [], [], [], [], [], [], [], [], [], [], [], [],
                                      [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], False)
            return

        DF1=op.algorithms.FickianDiffusion(network=self.network,phase=self.phase_inv)
        DF1.set_value_BC(pores=self.network.pores('left'),values=200000)
        DF1.set_value_BC(pores=self.network.pores('right'),values=100000)
        DF1.run()
        D2 = DF1.rate(pores=self.network.pores('left'))[0]

        SF2=op.algorithms.StokesFlow(network=self.network,phase=self.phase_inv)
        SF2.set_value_BC(pores=self.network.pores('bottom'),values=200000)
        SF2.set_value_BC(pores=self.network.pores('top'),values=100000)
        SF2.run()
        Q_tot_z=np.absolute(SF2.rate(pores=self.network.pores('bottom')))
        A_z=Lx*Ly

        DF2=op.algorithms.FickianDiffusion(network=self.network,phase=self.phase_inv)
        DF2.set_value_BC(pores=self.network.pores('bottom'),values=200000)
        DF2.set_value_BC(pores=self.network.pores('top'),values=100000)
        DF2.run()
        D3 = DF2.rate(pores=self.network.pores('bottom'))[0]

        D_tot = (D1+D2+D3)/3

        mu = np.mean(self.phase_inv['pore.viscosity'])
        delta_P = 100000

        K1 = float(Q_tot_x*mu*Lx/(delta_P*A_x))/(0.97*10**-15)
        K2 = float(Q_tot_y*mu*Ly/(delta_P*A_y))/(0.97*10**-15)
        K3 = float(Q_tot_z*mu*Lz/(delta_P*A_z))/(0.97*10**-15)
        self.K_tot = (K1+K2+K3)/3

        self.fix_number(connected_pores, overal_pores, K1, K2, K3)

        if not self.run:
            self.run = True
            self.onTimer = False
            self.percent.emit(0)
            self.finalsimulation.emit(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, [], [], [], [],
                                      [], [], [], [], [], [], [], [], [], [], [], [], [], [],
                                      [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], False)
            return

        tt += 1
        self.progress(tt, 10, 10)

        if method == "Ordinary Percolation":
            if residual != "":
                Np=self.network.Np
                res_sat = eval(residual)
                pNum = int(np.floor(res_sat * Np))
                res_pores = []
                for i in range (pNum):
                    res_pores.append(i)

            OP=op.algorithms.OrdinaryPercolation(network=self.network,phase=self.phase_inv)
            OP.setup(phase=self.phase_inv, pore_volume='pore.volume', throat_volume='throat.volume')
            OP.set_inlets(pores=self.network.pores('front'))
            if residual != "":
                OP.set_residual(pores=res_pores)
            OP.run()
            self.phase_inv.update(OP.results(Pc=0))
            pcdata = OP.get_intrusion_data()

            PC_data = {}

            PC_data['PCx'] = np.array(pcdata[0])
            PC_data['SWx'] = 1-np.array(pcdata[1])

            PC_data['PCx'] = [float(i) for i in PC_data['PCx']]
            PC_data['SWx'] = [float(i) for i in PC_data['SWx']]

            if not self.run:
                self.run = True
                self.onTimer = False
                self.percent.emit(0)
                self.finalsimulation.emit(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, [], [], [], [],
                                          [], [], [], [], [], [], [], [], [], [], [], [], [], [],
                                          [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], False)
                return

            OP1=op.algorithms.OrdinaryPercolation(network=self.network,phase=self.phase_inv)
            OP1.setup(phase=self.phase_inv, pore_volume='pore.volume', throat_volume='throat.volume')
            OP1.set_inlets(pores=self.network.pores('left'))
            if residual != "":
                OP1.set_residual(pores=res_pores)
            OP1.run()
            self.phase_inv.update(OP1.results(Pc=0))
            pcdata1 = OP1.get_intrusion_data()

            PC_data['PCy'] = np.array(pcdata1[0])
            PC_data['SWy'] = 1-np.array(pcdata1[1])

            PC_data['PCy'] = [float(i) for i in PC_data['PCy']]
            PC_data['SWy'] = [float(i) for i in PC_data['SWy']]

            if not self.run:
                self.run = True
                self.onTimer = False
                self.percent.emit(0)
                self.finalsimulation.emit(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, [], [], [], [],
                                          [], [], [], [], [], [], [], [], [], [], [], [], [], [],
                                          [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], False)
                return

            OP2=op.algorithms.OrdinaryPercolation(network=self.network,phase=self.phase_inv)
            OP2.setup(phase=self.phase_inv, pore_volume='pore.volume', throat_volume='throat.volume')
            OP2.set_inlets(pores=self.network.pores('top'))
            if residual != "":
                OP2.set_residual(pores=res_pores)
            OP2.run()
            self.phase_inv.update(OP2.results(Pc=0))
            pcdata2 = OP2.get_intrusion_data()

            PC_data['PCz'] = np.array(pcdata2[0])
            PC_data['SWz'] = 1-np.array(pcdata2[1])

            PC_data['PCz'] = [float(i) for i in PC_data['PCz']]
            PC_data['SWz'] = [float(i) for i in PC_data['SWz']]

            if not self.run:
                self.run = True
                self.onTimer = False
                self.percent.emit(0)
                self.finalsimulation.emit(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, [], [], [], [],
                                          [], [], [], [], [], [], [], [], [], [], [], [], [], [],
                                          [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], False)
                return

            self.phys_inv.add_model(model=pm.multiphase.conduit_conductance,
                                    propname='throat.conduit_hydraulic_conductance',
                                   throat_conductance='throat.hydraulic_conductance')
            self.phys_def.add_model(model=pm.multiphase.conduit_conductance,
                                    propname='throat.conduit_hydraulic_conductance',
                                    throat_conductance='throat.hydraulic_conductance')
            self.phys_inv.add_model(model=pm.multiphase.conduit_conductance,
                                    propname='throat.conduit_diffusive_conductance',
                                   throat_conductance='throat.diffusive_conductance')
            self.phys_def.add_model(model=pm.multiphase.conduit_conductance,
                                    propname='throat.conduit_diffusive_conductance',
                                    throat_conductance='throat.diffusive_conductance')

            tt += 1
            self.progress(tt, 10, 10)

            A = [A_x,A_y,A_z]
            Length = [Lx,Ly,Lz]
            bounds = [['front', 'back'], ['left', 'right'], ['top', 'bottom']]
            perm_air = {'0': [], '1': [], '2': []}
            perm_water = {'0': [], '1': [], '2': []}
            diff_air = {'0': [], '1': [], '2': []}
            diff_water = {'0': [], '1': [], '2': []}
            sat= []
            tot_vol = np.sum(self.network["pore.volume"]) + np.sum(self.network["throat.volume"])
            i = 1
            t = -1
            for Pc in np.unique(OP['pore.invasion_pressure']):
                t += 1
                self.progress(t, len(np.unique(OP['pore.invasion_pressure'])), len(np.unique(OP['pore.invasion_pressure'])))
                self.phase_inv.update(OP.results(Pc=Pc))
                self.phase_def['pore.occupancy'] = 1 - self.phase_inv['pore.occupancy']
                self.phase_def['throat.occupancy'] = 1 - self.phase_inv['throat.occupancy']
                self.phys_inv.regenerate_models()
                self.phys_def.regenerate_models()
                this_sat = 0
                this_sat += np.sum(self.network["pore.volume"][self.phase_inv["pore.occupancy"] == 1])
                this_sat += np.sum(self.network["throat.volume"][self.phase_inv["throat.occupancy"] == 1])
                sat.append(this_sat)
                i = 0
                for bound_increment in range(len(bounds)):
                    BC1_pores = self.network.pores(labels=bounds[bound_increment][0])
                    BC2_pores = self.network.pores(labels=bounds[bound_increment][1])
                    ST_1 = op.algorithms.StokesFlow(network=self.network)
                    ST_1.setup(phase=self.phase_inv, conductance='throat.conduit_hydraulic_conductance')
                    ST_1.set_value_BC(values=0.6, pores=BC1_pores)
                    ST_1.set_value_BC(values=0.2, pores=BC2_pores)
                    ST_1.run()
                    eff_perm = ST_1.calc_effective_permeability(domain_area=A[i], domain_length=Length[i])
                    perm_air[str(bound_increment)].append(eff_perm)
                    DF_1 = op.algorithms.FickianDiffusion(network=self.network)
                    DF_1.setup(phase=self.phase_inv, conductance='throat.conduit_diffusive_conductance')
                    DF_1.set_value_BC(values=0.6, pores=BC1_pores)
                    DF_1.set_value_BC(values=0.2, pores=BC2_pores)
                    DF_1.run()
                    eff_diff = DF_1.calc_effective_diffusivity(domain_area=A[i], domain_length=Length[i])
                    diff_air[str(bound_increment)].append(eff_diff)
                    ST_2 = op.algorithms.StokesFlow(network=self.network)
                    ST_2.setup(phase=self.phase_def, conductance='throat.conduit_hydraulic_conductance')
                    ST_2.set_value_BC(values=0.6, pores=BC1_pores)
                    ST_2.set_value_BC(values=0.2, pores=BC2_pores)
                    ST_2.run()
                    eff_perm = ST_2.calc_effective_permeability(domain_area=A[i], domain_length=Length[i])
                    perm_water[str(bound_increment)].append(eff_perm)
                    DF_2 = op.algorithms.FickianDiffusion(network=self.network)
                    DF_2.setup(phase=self.phase_def, conductance='throat.conduit_diffusive_conductance')
                    DF_2.set_value_BC(values=0.6, pores=BC1_pores)
                    DF_2.set_value_BC(values=0.2, pores=BC2_pores)
                    DF_2.run()
                    eff_diff = DF_2.calc_effective_diffusivity(domain_area=A[i], domain_length=Length[i])
                    diff_water[str(bound_increment)].append(eff_diff)
                    self.network.project.purge_object(ST_1)
                    self.network.project.purge_object(ST_2)
                    self.network.project.purge_object(DF_1)
                    self.network.project.purge_object(DF_2)
                    i = i + 1

            if not self.run:
                self.run = True
                self.onTimer = False
                self.percent.emit(0)
                self.finalsimulation.emit(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, [], [], [], [],
                                          [], [], [], [], [], [], [], [], [], [], [], [], [], [],
                                          [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], False)
                return

            sat = np.asarray(sat)
            sat /= tot_vol
            rel_perm_air_x    =  np.asarray(perm_air['0'])
            rel_perm_air_x   =  (rel_perm_air_x/rel_perm_air_x[0]) * 1e-6
            rel_perm_air_y    =  np.asarray(perm_air['1'])
            rel_perm_air_y   =  (rel_perm_air_y/rel_perm_air_y[0]) * 1e-6
            rel_perm_air_z    =  np.asarray(perm_air['2'])
            rel_perm_air_z   =  (rel_perm_air_z/rel_perm_air_z[0]) * 1e-6
            rel_perm_water_x  =  np.asarray(perm_water['0'])
            rel_perm_water_x =  (rel_perm_water_x/rel_perm_water_x[-1]) * 1e-6
            rel_perm_water_y  =  np.asarray(perm_water['1'])
            rel_perm_water_y =  (rel_perm_water_y/rel_perm_water_y[-1]) * 1e-6
            rel_perm_water_z  =  np.asarray(perm_water['2'])
            rel_perm_water_z =  (rel_perm_water_z/rel_perm_water_z[-1]) * 1e-6

            rel_diff_air_x    =  np.asarray(diff_air['0'])
            rel_diff_air_x   /=  rel_diff_air_x[0] * 1e6
            rel_diff_air_y    =  np.asarray(diff_air['1'])
            rel_diff_air_y   /=  rel_diff_air_y[0] * 1e6
            rel_diff_air_z    =  np.asarray(diff_air['2'])
            rel_diff_air_z   /=  rel_diff_air_z[0] * 1e6
            rel_diff_water_x  =  np.asarray(diff_water['0'])
            rel_diff_water_x /=  rel_diff_water_x[-1] * 1e6
            rel_diff_water_y  =  np.asarray(diff_water['1'])
            rel_diff_water_y /=  rel_diff_water_y[-1] * 1e6
            rel_diff_water_z  =  np.asarray(diff_water['2'])
            rel_diff_water_z /=  rel_diff_water_z[-1] * 1e6

            Krdata = {}
            Krdata['Swx'] = sat
            Krdata['Swy'] = sat
            Krdata['Swz'] = sat
            Krdata['Krwx'] = rel_perm_air_x
            Krdata['Krnwx'] = rel_perm_water_x
            Krdata['Krwy'] = rel_perm_air_y
            Krdata['Krnwy'] = rel_perm_water_y
            Krdata['Krwz'] = rel_perm_air_z
            Krdata['Krnwz'] = rel_perm_water_z

            Krdata['Swx'] = [float(i) for i in Krdata['Swx']]
            Krdata['Swy'] = [float(i) for i in Krdata['Swy']]
            Krdata['Swz'] = [float(i) for i in Krdata['Swz']]
            Krdata['Krwx'] = [float(i) for i in Krdata['Krwx']]
            Krdata['Krnwx'] = [float(i) for i in Krdata['Krnwx']]
            Krdata['Krwy'] = [float(i) for i in Krdata['Krwy']]
            Krdata['Krnwy'] = [float(i) for i in Krdata['Krnwy']]
            Krdata['Krwz'] = [float(i) for i in Krdata['Krwz']]
            Krdata['Krnwz'] = [float(i) for i in Krdata['Krnwz']]

            Drdata = {}
            Drdata['Swx'] = sat
            Drdata['Swy'] = sat
            Drdata['Swz'] = sat
            Drdata['Drwx'] = rel_diff_air_x
            Drdata['Drnwx'] = rel_diff_water_x
            Drdata['Drwy'] = rel_diff_air_y
            Drdata['Drnwy'] = rel_diff_water_y
            Drdata['Drwz'] = rel_diff_air_z
            Drdata['Drnwz'] = rel_diff_water_z

            Drdata['Swx'] = [float(i) for i in Drdata['Swx']]
            Drdata['Swt'] = [float(i) for i in Drdata['Swy']]
            Drdata['Swz'] = [float(i) for i in Drdata['Swz']]
            Drdata['Drwx'] = [float(i) for i in Drdata['Drwx']]
            Drdata['Drnwx'] = [float(i) for i in Drdata['Drnwx']]
            Drdata['Drwy'] = [float(i) for i in Drdata['Drwy']]
            Drdata['Drnwy'] = [float(i) for i in Drdata['Drnwy']]
            Drdata['Drwz'] = [float(i) for i in Drdata['Drwz']]
            Drdata['Drnwz'] = [float(i) for i in Drdata['Drnwz']]

        elif (method == "Invasion Percolation"):
            if (residual != ""):
                Np=self.network.Np
                res_sat = eval(residual)
                pNum = int(np.floor(res_sat * Np))
                res_pores = []
                for i in range (pNum):
                    res_pores.append(i)

            ip = op.algorithms.InvasionPercolation(network=self.network)
            ip.setup(phase=self.phase_inv)
            Finlets_init = self.network.pores('front')
            Finlets=([Finlets_init[x] for x in range(0, len(Finlets_init))])
            ip.set_inlets(pores=Finlets)
            ip.run()
            if (trapping):
                ip.apply_trapping(outlets=self.network.pores('back'))
            inv_points = np.arange(0, 100, 1)
            self.phase_inv.update(ip.results())
            data = ip.get_intrusion_data()

            if not self.run:
                self.run = True
                self.onTimer = False
                self.percent.emit(0)
                self.finalsimulation.emit(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, [], [], [], [],
                                          [], [], [], [], [], [], [], [], [], [], [], [], [], [],
                                          [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], False)
                return

            rp = RelativePermeability(network=self.network, invading_phase=self.phase_inv.name, defending_phase=self.phase_def.name, invasion_sequence='invasion_sequence',
                     flow_inlets={'x': 'front'}, flow_outlets={'x': 'back'})
            rp.run()
            data1_kr = rp.get_Kr_data()
            Krdata = {}
            Krdata['Swx'] = 1 - np.array(data1_kr['sat']['x'])
            Krdata['Krwx'] = np.array(data1_kr['relperm_wp']['x'])
            Krdata['Krnwx'] = np.array(data1_kr['relperm_nwp']['x'])

            rd = RelativeDiffusivity(network=self.network, invading_phase=self.phase_inv.name, defending_phase=self.phase_def.name, invasion_sequence='invasion_sequence',
                     flow_inlets={'x': 'front'}, flow_outlets={'x': 'back'})
            rd.run()
            data1_dr = rd.get_Dr_data()
            Drdata = {}
            Drdata['Swx'] = 1 - np.array(data1_dr['sat']['x'])
            Drdata['Drwx'] = np.array(data1_dr['reldiff_wp']['x'])
            Drdata['Drnwx'] = np.array(data1_dr['reldiff_nwp']['x'])
            tt += 0.25
            self.progress(tt, 10, 10)

            if not self.run:
                self.run = True
                self.onTimer = False
                self.percent.emit(0)
                self.finalsimulation.emit(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, [], [], [], [],
                                          [], [], [], [], [], [], [], [], [], [], [], [], [], [],
                                          [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], False)
                return

            ##################################################################
            ip1 = op.algorithms.InvasionPercolation(network=self.network)
            ip1.setup(phase=self.phase_inv)
            Finlets_init = self.network.pores('left')
            Finlets=([Finlets_init[x] for x in range(0, len(Finlets_init))])
            ip1.set_inlets(pores=Finlets)
            ip1.run()
            if (trapping):
                ip1.apply_trapping(outlets=self.network.pores('right'))
            inv_points = np.arange(0, 100, 1)
            self.phase_inv.update(ip1.results())
            data1 = ip1.get_intrusion_data()

            if not self.run:
                self.run = True
                self.onTimer = False
                self.percent.emit(0)
                self.finalsimulation.emit(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, [], [], [], [],
                                          [], [], [], [], [], [], [], [], [], [], [], [], [], [],
                                          [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], False)
                return

            rp = RelativePermeability(network=self.network, invading_phase=self.phase_inv.name, defending_phase=self.phase_def.name, invasion_sequence='invasion_sequence',
                     flow_inlets={'y': 'left'}, flow_outlets={'y': 'right'})
            rp.run()
            data2_kr = rp.get_Kr_data()

            Krdata['Swy'] = 1 - np.array(data2_kr['sat']['y'])
            Krdata['Krwy'] = np.array(data2_kr['relperm_wp']['y'])
            Krdata['Krnwy'] = np.array(data2_kr['relperm_nwp']['y'])

            rd = RelativeDiffusivity(network=self.network, invading_phase=self.phase_inv.name, defending_phase=self.phase_def.name, invasion_sequence='invasion_sequence',
                     flow_inlets={'y': 'left'}, flow_outlets={'y': 'right'})
            rd.run()
            data2_dr = rd.get_Dr_data()

            Drdata['Swy'] = 1 - np.array(data2_dr['sat']['y'])
            Drdata['Drwy'] = np.array(data2_dr['reldiff_wp']['y'])
            Drdata['Drnwy'] = np.array(data2_dr['reldiff_nwp']['y'])
            tt += 0.25
            self.progress(tt, 10, 10)

            if not self.run:
                self.run = True
                self.onTimer = False
                self.percent.emit(0)
                self.finalsimulation.emit(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, [], [], [], [],
                                          [], [], [], [], [], [], [], [], [], [], [], [], [], [],
                                          [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], False)
                return
            ###################################################################
            ip2 = op.algorithms.InvasionPercolation(network=self.network)
            ip2.setup(phase=self.phase_inv)
            Finlets_init = self.network.pores('top')
            Finlets=([Finlets_init[x] for x in range(0, len(Finlets_init))])
            ip2.set_inlets(pores=Finlets)
            ip2.run()
            if (trapping):
                ip2.apply_trapping(outlets=self.network.pores('bottom'))
            inv_points = np.arange(0, 100, 1)
            self.phase_inv.update(ip2.results())
            data2 = ip2.get_intrusion_data()

            if not self.run:
                self.run = True
                self.onTimer = False
                self.percent.emit(0)
                self.finalsimulation.emit(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, [], [], [], [],
                                          [], [], [], [], [], [], [], [], [], [], [], [], [], [],
                                          [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], False)
                return

            rp = RelativePermeability(network=self.network, invading_phase=self.phase_inv.name, defending_phase=self.phase_def.name, invasion_sequence='invasion_sequence',
            flow_inlets={'z': 'top'}, flow_outlets={'z': 'bottom'})
            rp.run()
            data3_kr = rp.get_Kr_data()

            Krdata['Swz'] = 1 - np.array(data3_kr['sat']['z'])
            Krdata['Krwz'] = np.array(data3_kr['relperm_wp']['z'])
            Krdata['Krnwz'] = np.array(data3_kr['relperm_nwp']['z'])

            rd = RelativeDiffusivity(network=self.network, invading_phase=self.phase_inv.name, defending_phase=self.phase_def.name, invasion_sequence='invasion_sequence',
                                 flow_inlets={'z': 'top'}, flow_outlets={'z': 'bottom'})
            rd.run()
            data3_dr = rd.get_Dr_data()

            Drdata['Swz'] = 1 - np.array(data3_dr['sat']['z'])
            Drdata['Drwz'] = np.array(data3_dr['reldiff_wp']['z'])
            Drdata['Drnwz'] = np.array(data3_dr['reldiff_nwp']['z'])

            tt += 0.5
            self.progress(tt, 10, 10)

            if not self.run:
                self.run = True
                self.onTimer = False
                self.percent.emit(0)
                self.finalsimulation.emit(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, [], [], [], [],
                                          [], [], [], [], [], [], [], [], [], [], [], [], [], [],
                                          [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], False)
                return

            PC_data = {}
            PC_data['PCx'] = data.Pcap
            PC_data['SWx'] = 1-data.S_tot
            PC_data['PCy'] = data1.Pcap
            PC_data['SWy'] = 1-data1.S_tot
            PC_data['PCz'] = data2.Pcap
            PC_data['SWz'] = 1-data2.S_tot

            PC_data['PCx'] = [float(i) for i in PC_data['PCx']]
            PC_data['SWx'] = [float(i) for i in PC_data['SWx']]

            PC_data['PCy'] = [float(i) for i in PC_data['PCy']]
            PC_data['SWy'] = [float(i) for i in PC_data['SWy']]

            PC_data['PCz'] = [float(i) for i in PC_data['PCz']]
            PC_data['SWz'] = [float(i) for i in PC_data['SWz']]

            Krdata['Swx'] = [float(i) for i in Krdata['Swx']]
            Krdata['Swy'] = [float(i) for i in Krdata['Swy']]
            Krdata['Swz'] = [float(i) for i in Krdata['Swz']]
            Krdata['Krwx'] = [float(i) for i in Krdata['Krwx']]
            Krdata['Krnwx'] = [float(i) for i in Krdata['Krnwx']]
            Krdata['Krwy'] = [float(i) for i in Krdata['Krwy']]
            Krdata['Krnwy'] = [float(i) for i in Krdata['Krnwy']]
            Krdata['Krwz'] = [float(i) for i in Krdata['Krwz']]
            Krdata['Krnwz'] = [float(i) for i in Krdata['Krnwz']]

            Drdata['Swx'] = [float(i) for i in Drdata['Swx']]
            Drdata['Swy'] = [float(i) for i in Drdata['Swy']]
            Drdata['Swz'] = [float(i) for i in Drdata['Swz']]
            Drdata['Drwx'] = [float(i) for i in Drdata['Drwx']]
            Drdata['Drnwx'] = [float(i) for i in Drdata['Drnwx']]
            Drdata['Drwy'] = [float(i) for i in Drdata['Drwy']]
            Drdata['Drnwy'] = [float(i) for i in Drdata['Drnwy']]
            Drdata['Drwz'] = [float(i) for i in Drdata['Drwz']]
            Drdata['Drnwz'] = [float(i) for i in Drdata['Drnwz']]

            ###################################################################
        else:
            if (residual != ""):
                Np=self.network.Np
                res_sat = eval(residual)
                pNum = int(np.floor(res_sat * Np))
                res_pores = []
                for i in range (pNum):
                    res_pores.append(i)

            self.phys_inv.add_model(propname='pore.entry_pressure',
                               model = mods.capillary_pressure.washburn, diameter="pore.diameter")
            self.phys_inv.regenerate_models()
            self.phys_def.add_model(propname='pore.entry_pressure',
                               model = mods.capillary_pressure.washburn, diameter="pore.diameter")
            self.phys_def.regenerate_models()

            ip = op.algorithms.MixedInvasionPercolation(network=self.network)
            ip.setup(phase=self.phase_inv, pore_entry_pressure='pore.entry_pressure')
            Finlets_init = self.network.pores('front')
            Finlets=([Finlets_init[x] for x in range(0, len(Finlets_init))])
            ip.set_inlets(pores=Finlets)
            if (residual != ""):
                ip.set_residual(pores=res_pores)
            ip.run()
            if (trapping):
                ip.set_outlets(self.network.pores('back'))
                ip.apply_trapping()
            inv_points = np.arange(0, 100, 1)
            self.phase_inv.update(ip.results(Pc=inv_points.max()))
            data = ip.get_intrusion_data()

            if not self.run:
                self.run = True
                self.onTimer = False
                self.percent.emit(0)
                self.finalsimulation.emit(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, [], [], [], [],
                                          [], [], [], [], [], [], [], [], [], [], [], [], [], [],
                                          [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], False)
                return
            ################################################################################
            ip1 = op.algorithms.MixedInvasionPercolation(network=self.network)
            ip1.setup(phase=self.phase_inv, pore_entry_pressure='pore.entry_pressure')
            Finlets_init = self.network.pores('left')
            Finlets=([Finlets_init[x] for x in range(0, len(Finlets_init))])
            ip1.set_inlets(pores=Finlets)
            if (residual != ""):
                ip1.set_residual(pores=res_pores)
            ip1.run()
            if (trapping):
                ip1.set_outlets(self.network.pores('right'))
                ip1.apply_trapping()
            inv_points = np.arange(0, 100, 1)
            self.phase_inv.update(ip1.results(Pc=inv_points.max()))
            data1 = ip1.get_intrusion_data()

            if not self.run:
                self.run = True
                self.onTimer = False
                self.percent.emit(0)
                self.finalsimulation.emit(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, [], [], [], [],
                                          [], [], [], [], [], [], [], [], [], [], [], [], [], [],
                                          [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], False)
                return
            ################################################################################
            ip2 = op.algorithms.MixedInvasionPercolation(network=self.network)
            ip2.setup(phase=self.phase_inv, pore_entry_pressure='pore.entry_pressure')
            Finlets_init = self.network.pores('top')
            Finlets=([Finlets_init[x] for x in range(0, len(Finlets_init))])
            ip2.set_inlets(pores=Finlets)
            if (residual != ""):
                ip2.set_residual(pores=res_pores)
            ip2.run()
            if (trapping):
                ip2.set_outlets(self.network.pores('bottom'))
                ip2.apply_trapping()
            inv_points = np.arange(0, 100, 1)
            self.phase_inv.update(ip2.results(Pc=inv_points.max()))
            data2 = ip2.get_intrusion_data()

            if not self.run:
                self.run = True
                self.onTimer = False
                self.percent.emit(0)
                self.finalsimulation.emit(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, [], [], [], [],
                                          [], [], [], [], [], [], [], [], [], [], [], [], [], [],
                                          [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], False)
                return

            tt += 1
            self.progress(tt, 10, 10)

            PC_data = {}
            PC_data['PCx'] = data.Pcap
            PC_data['SWx'] = 1-data.S_tot
            PC_data['PCy'] = data1.Pcap
            PC_data['SWy'] = 1-data1.S_tot
            PC_data['PCz'] = data2.Pcap
            PC_data['SWz'] = 1-data2.S_tot
            PC_data['PCx'] = [float(i) for i in PC_data['PCx']]
            PC_data['SWx'] = [float(i) for i in PC_data['SWx']]

            PC_data['PCy'] = [float(i) for i in PC_data['PCy']]
            PC_data['SWy'] = [float(i) for i in PC_data['SWy']]

            PC_data['PCz'] = [float(i) for i in PC_data['PCz']]
            PC_data['SWz'] = [float(i) for i in PC_data['SWz']]
            ################################################################################

            A = [A_x,A_y,A_z]
            Length = [Lx,Ly,Lz]
            bounds = [['front', 'back'], ['left', 'right'], ['top', 'bottom']]
            perm_air = {'0': [], '1': [], '2': []}
            perm_water = {'0': [], '1': [], '2': []}
            diff_air = {'0': [], '1': [], '2': []}
            diff_water = {'0': [], '1': [], '2': []}
            satx= []
            saty = []
            satz = []

            tot_vol = np.sum(self.network["pore.volume"]) + np.sum(self.network["throat.volume"])

            i = 0
            Pc = np.unique(ip['throat.invasion_pressure'])
            for j in range(1, len(np.unique(ip['throat.invasion_pressure']))):
                self.progress(j, len(np.unique(ip['throat.invasion_pressure'])), len(np.unique(ip['throat.invasion_pressure'])))
                res = ip.results(Pc=Pc[j])
                up_data = {
                    'pore.occupancy': np.array(res['pore.occupancy'], dtype=bool),
                    'throat.occupancy': np.array(res['throat.occupancy'], dtype=bool)
                    }
                self.phase_inv.update(up_data)
                self.phase_def['pore.occupancy'] = ~self.phase_inv['pore.occupancy']
                self.phase_def['throat.occupancy'] = ~self.phase_inv['throat.occupancy']
                self.phys_inv.regenerate_models()
                self.phys_def.regenerate_models()
                this_sat = 0
                this_sat += np.sum(self.network["pore.volume"][self.phase_inv["pore.occupancy"] == 1])
                this_sat += np.sum(self.network["throat.volume"][self.phase_inv["throat.occupancy"] == 1])
                satx.append(this_sat)
                BC1_pores = self.network.pores(labels=bounds[i][0])
                BC2_pores = self.network.pores(labels=bounds[i][1])
                ST_1 = op.algorithms.StokesFlow(network=self.network)
                ST_1.setup(phase=self.phase_inv, conductance='throat.conduit_hydraulic_conductance')
                ST_1.set_value_BC(values=0.6, pores=BC1_pores)
                ST_1.set_value_BC(values=0.2, pores=BC2_pores)
                ST_1.run()
                eff_perm = ST_1.calc_effective_permeability(domain_area=A[i], domain_length=Length[i])
                perm_air[str(i)].append(eff_perm)
                DF_1 = op.algorithms.FickianDiffusion(network=self.network)
                DF_1.setup(phase=self.phase_inv, conductance='throat.conduit_diffusive_conductance')
                DF_1.set_value_BC(values=0.6, pores=BC1_pores)
                DF_1.set_value_BC(values=0.2, pores=BC2_pores)
                DF_1.run()
                eff_diff = DF_1.calc_effective_diffusivity(domain_area=A[i], domain_length=Length[i])
                diff_air[str(i)].append(eff_diff)
                ST_2 = op.algorithms.StokesFlow(network=self.network)
                ST_2.setup(phase=self.phase_def, conductance='throat.conduit_hydraulic_conductance')
                ST_2.set_value_BC(values=0.6, pores=BC1_pores)
                ST_2.set_value_BC(values=0.2, pores=BC2_pores)
                ST_2.run()
                eff_perm = ST_2.calc_effective_permeability(domain_area=A[i], domain_length=Length[i])
                perm_water[str(i)].append(eff_perm)
                DF_2 = op.algorithms.FickianDiffusion(network=self.network)
                DF_2.setup(phase=self.phase_def, conductance='throat.conduit_diffusive_conductance')
                DF_2.set_value_BC(values=0.6, pores=BC1_pores)
                DF_2.set_value_BC(values=0.2, pores=BC2_pores)
                DF_2.run()
                eff_diff = DF_2.calc_effective_diffusivity(domain_area=A[i], domain_length=Length[i])
                diff_water[str(i)].append(eff_diff)
                self.network.project.purge_object(ST_1)
                self.network.project.purge_object(ST_2)
                self.network.project.purge_object(DF_1)
                self.network.project.purge_object(DF_2)

            if not self.run:
                self.run = True
                self.onTimer = False
                self.percent.emit(0)
                self.finalsimulation.emit(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, [], [], [], [],
                                          [], [], [], [], [], [], [], [], [], [], [], [], [], [],
                                          [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], False)
                return

            i=1
            Pc = np.unique(ip1['throat.invasion_pressure'])
            for j in range(1, len(np.unique(ip1['throat.invasion_pressure']))):
                self.progress(j, len(np.unique(ip1['throat.invasion_pressure'])), len(np.unique(ip1['throat.invasion_pressure'])))
                res = ip1.results(Pc=Pc[j])
                up_data = {
                    'pore.occupancy': np.array(res['pore.occupancy'], dtype=bool),
                    'throat.occupancy': np.array(res['throat.occupancy'], dtype=bool)
                    }
                self.phase_inv.update(up_data)
                self.phase_def['pore.occupancy'] = ~self.phase_inv['pore.occupancy']
                self.phase_def['throat.occupancy'] = ~self.phase_inv['throat.occupancy']
                self.phys_inv.regenerate_models()
                self.phys_def.regenerate_models()
                this_sat = 0
                this_sat += np.sum(self.network["pore.volume"][self.phase_inv["pore.occupancy"] == 1])
                this_sat += np.sum(self.network["throat.volume"][self.phase_inv["throat.occupancy"] == 1])
                saty.append(this_sat)
                BC1_pores = self.network.pores(labels=bounds[i][0])
                BC2_pores = self.network.pores(labels=bounds[i][1])
                ST_1 = op.algorithms.StokesFlow(network=self.network)
                ST_1.setup(phase=self.phase_inv, conductance='throat.conduit_hydraulic_conductance')
                ST_1.set_value_BC(values=0.6, pores=BC1_pores)
                ST_1.set_value_BC(values=0.2, pores=BC2_pores)
                ST_1.run()
                eff_perm = ST_1.calc_effective_permeability(domain_area=A[i], domain_length=Length[i])
                perm_air[str(i)].append(eff_perm)
                DF_1 = op.algorithms.FickianDiffusion(network=self.network)
                DF_1.setup(phase=self.phase_inv, conductance='throat.conduit_diffusive_conductance')
                DF_1.set_value_BC(values=0.6, pores=BC1_pores)
                DF_1.set_value_BC(values=0.2, pores=BC2_pores)
                DF_1.run()
                eff_diff = DF_1.calc_effective_diffusivity(domain_area=A[i], domain_length=Length[i])
                diff_air[str(i)].append(eff_diff)
                ST_2 = op.algorithms.StokesFlow(network=self.network)
                ST_2.setup(phase=self.phase_def, conductance='throat.conduit_hydraulic_conductance')
                ST_2.set_value_BC(values=0.6, pores=BC1_pores)
                ST_2.set_value_BC(values=0.2, pores=BC2_pores)
                ST_2.run()
                eff_perm = ST_2.calc_effective_permeability(domain_area=A[i], domain_length=Length[i])
                perm_water[str(i)].append(eff_perm)
                DF_2 = op.algorithms.FickianDiffusion(network=self.network)
                DF_2.setup(phase=self.phase_def, conductance='throat.conduit_diffusive_conductance')
                DF_2.set_value_BC(values=0.6, pores=BC1_pores)
                DF_2.set_value_BC(values=0.2, pores=BC2_pores)
                DF_2.run()
                eff_diff = DF_2.calc_effective_diffusivity(domain_area=A[i], domain_length=Length[i])
                diff_water[str(i)].append(eff_diff)
                self.network.project.purge_object(ST_1)
                self.network.project.purge_object(ST_2)
                self.network.project.purge_object(DF_1)
                self.network.project.purge_object(DF_2)

            if not self.run:
                self.run = True
                self.onTimer = False
                self.percent.emit(0)
                self.finalsimulation.emit(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, [], [], [], [],
                                          [], [], [], [], [], [], [], [], [], [], [], [], [], [],
                                          [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], False)
                return

            i = 2
            Pc = np.unique(ip2['throat.invasion_pressure'])
            for j in range(1, len(np.unique(ip2['throat.invasion_pressure']))):
                self.progress(j, len(np.unique(ip2['throat.invasion_pressure'])), len(np.unique(ip2['throat.invasion_pressure'])))
                res = ip2.results(Pc=Pc[j])
                up_data = {
                    'pore.occupancy': np.array(res['pore.occupancy'], dtype=bool),
                    'throat.occupancy': np.array(res['throat.occupancy'], dtype=bool)
                    }
                self.phase_inv.update(up_data)
                self.phase_def['pore.occupancy'] = ~self.phase_inv['pore.occupancy']
                self.phase_def['throat.occupancy'] = ~self.phase_inv['throat.occupancy']
                self.phys_inv.regenerate_models()
                self.phys_def.regenerate_models()
                this_sat = 0
                this_sat += np.sum(self.network["pore.volume"][self.phase_inv["pore.occupancy"] == 1])
                this_sat += np.sum(self.network["throat.volume"][self.phase_inv["throat.occupancy"] == 1])
                satz.append(this_sat)
                BC1_pores = self.network.pores(labels=bounds[i][0])
                BC2_pores = self.network.pores(labels=bounds[i][1])
                ST_1 = op.algorithms.StokesFlow(network=self.network)
                ST_1.setup(phase=self.phase_inv, conductance='throat.conduit_hydraulic_conductance')
                ST_1.set_value_BC(values=0.6, pores=BC1_pores)
                ST_1.set_value_BC(values=0.2, pores=BC2_pores)
                ST_1.run()
                eff_perm = ST_1.calc_effective_permeability(domain_area=A[i], domain_length=Length[i])
                perm_air[str(i)].append(eff_perm)
                DF_1 = op.algorithms.FickianDiffusion(network=self.network)
                DF_1.setup(phase=self.phase_inv, conductance='throat.conduit_diffusive_conductance')
                DF_1.set_value_BC(values=0.6, pores=BC1_pores)
                DF_1.set_value_BC(values=0.2, pores=BC2_pores)
                DF_1.run()
                eff_diff = DF_1.calc_effective_diffusivity(domain_area=A[i], domain_length=Length[i])
                diff_air[str(i)].append(eff_diff)
                ST_2 = op.algorithms.StokesFlow(network=self.network)
                ST_2.setup(phase=self.phase_def, conductance='throat.conduit_hydraulic_conductance')
                ST_2.set_value_BC(values=0.6, pores=BC1_pores)
                ST_2.set_value_BC(values=0.2, pores=BC2_pores)
                ST_2.run()
                eff_perm = ST_2.calc_effective_permeability(domain_area=A[i], domain_length=Length[i])
                perm_water[str(i)].append(eff_perm)
                DF_2 = op.algorithms.FickianDiffusion(network=self.network)
                DF_2.setup(phase=self.phase_def, conductance='throat.conduit_diffusive_conductance')
                DF_2.set_value_BC(values=0.6, pores=BC1_pores)
                DF_2.set_value_BC(values=0.2, pores=BC2_pores)
                DF_2.run()
                eff_diff = DF_2.calc_effective_diffusivity(domain_area=A[i], domain_length=Length[i])
                diff_water[str(i)].append(eff_diff)
                self.network.project.purge_object(ST_1)
                self.network.project.purge_object(ST_2)
                self.network.project.purge_object(DF_1)
                self.network.project.purge_object(DF_2)

            if not self.run:
                self.run = True
                self.onTimer = False
                self.percent.emit(0)
                self.finalsimulation.emit(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, [], [], [], [],
                                          [], [], [], [], [], [], [], [], [], [], [], [], [], [],
                                          [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], False)
                return


            satx = np.asarray(satx)
            satx /= tot_vol

            saty = np.asarray(saty)
            saty /= tot_vol

            satz = np.asarray(satz)
            satz /= tot_vol

            rel_perm_air_x    =  np.asarray(perm_air['0'])
            rel_perm_air_x   =  ((rel_perm_air_x-rel_perm_air_x[0])/(K1-rel_perm_air_x[0]))
            rel_perm_air_y    =  np.asarray(perm_air['1'])
            rel_perm_air_y   =  ((rel_perm_air_y-rel_perm_air_y[0])/(K2-rel_perm_air_y[0]))
            rel_perm_air_z    =  np.asarray(perm_air['2'])
            rel_perm_air_z   =  ((rel_perm_air_z-rel_perm_air_z[0])/(K3-rel_perm_air_z[0]))
            rel_perm_water_x  =  np.asarray(perm_water['0'])
            rel_perm_water_x =  ((rel_perm_water_x-rel_perm_water_x[-1])/(rel_perm_water_x[0]-rel_perm_water_x[-1]))
            rel_perm_water_y  =  np.asarray(perm_water['1'])
            rel_perm_water_y =  ((rel_perm_water_y-rel_perm_water_y[-1])/(rel_perm_water_y[0]-rel_perm_water_y[-1]))
            rel_perm_water_z  =  np.asarray(perm_water['2'])
            rel_perm_water_z =  ((rel_perm_water_z-rel_perm_water_z[-1])/(rel_perm_water_z[0]-rel_perm_water_z[-1]))

            rel_diff_air_x    =  np.asarray(diff_air['0'])
            rel_diff_air_x   =  ((rel_diff_air_x-rel_diff_air_x[0])/(D1-rel_diff_air_x[0]))
            rel_diff_air_y    =  np.asarray(diff_air['1'])
            rel_diff_air_y   =  ((rel_diff_air_y-rel_diff_air_y[0])/(D2-rel_diff_air_y[0]))
            rel_diff_air_z    =  np.asarray(diff_air['2'])
            rel_diff_air_z   =  ((rel_diff_air_z-rel_diff_air_z[0])/(D3-rel_diff_air_z[0]))
            rel_diff_water_x  =  np.asarray(diff_water['0'])
            rel_diff_water_x =  ((rel_diff_water_x-rel_diff_water_x[-1])/(rel_diff_water_x[0]-rel_diff_water_x[-1]))
            rel_diff_water_y  =  np.asarray(diff_water['1'])
            rel_diff_water_y =  ((rel_diff_water_y-rel_diff_water_y[-1])/(rel_diff_water_y[0]-rel_diff_water_y[-1]))
            rel_diff_water_z  =  np.asarray(diff_water['2'])
            rel_diff_water_z =  ((rel_diff_water_z-rel_diff_water_z[-1])/(rel_diff_water_z[0]-rel_diff_water_z[-1]))


            Krdata = {}
            Krdata['Swx'] = 1-satx
            Krdata['Swy'] = 1-saty
            Krdata['Swz'] = 1-satz
            Krdata['Krnwx'] = rel_perm_air_x
            Krdata['Krwx'] = rel_perm_water_x
            Krdata['Krnwy'] = rel_perm_air_y
            Krdata['Krwy'] = rel_perm_water_y
            Krdata['Krnwz'] = rel_perm_air_z
            Krdata['Krwz'] = rel_perm_water_z

            Krdata['Swx'] = [float(i) for i in Krdata['Swx']]
            Krdata['Swy'] = [float(i) for i in Krdata['Swy']]
            Krdata['Swz'] = [float(i) for i in Krdata['Swz']]
            Krdata['Krwx'] = [float(i) for i in Krdata['Krwx']]
            Krdata['Krnwx'] = [float(i) for i in Krdata['Krnwx']]
            Krdata['Krwy'] = [float(i) for i in Krdata['Krwy']]
            Krdata['Krnwy'] = [float(i) for i in Krdata['Krnwy']]
            Krdata['Krwz'] = [float(i) for i in Krdata['Krwz']]
            Krdata['Krnwz'] = [float(i) for i in Krdata['Krnwz']]

            Drdata = {}
            Drdata['Swx'] = 1 - satx
            Drdata['Swy'] = 1 - saty
            Drdata['Swz'] = 1 - satz
            Drdata['Drwx'] = rel_diff_air_x
            Drdata['Drnwx'] = rel_diff_water_x
            Drdata['Drwy'] = rel_diff_air_y
            Drdata['Drnwy'] = rel_diff_water_y
            Drdata['Drwz'] = rel_diff_air_z
            Drdata['Drnwz'] = rel_diff_water_z

            Drdata['Swx'] = [float(i) for i in Drdata['Swx']]
            Drdata['Swy'] = [float(i) for i in Drdata['Swy']]
            Drdata['Swz'] = [float(i) for i in Drdata['Swz']]
            Drdata['Drwx'] = [float(i) for i in Drdata['Drwx']]
            Drdata['Drnwx'] = [float(i) for i in Drdata['Drnwx']]
            Drdata['Drwy'] = [float(i) for i in Drdata['Drwy']]
            Drdata['Drnwy'] = [float(i) for i in Drdata['Drnwy']]
            Drdata['Drwz'] = [float(i) for i in Drdata['Drwz']]
            Drdata['Drnwz'] = [float(i) for i in Drdata['Drnwz']]

        if not self.run:
            self.run = True
            self.onTimer = False
            self.percent.emit(0)
            self.finalsimulation.emit(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, [], [], [], [],
                                      [], [], [], [], [], [], [], [], [], [], [], [], [], [],
                                      [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], False)
            return

        pdiam = [r*1000000 for r in self.network['pore.diameter'] ]
        kde3 = stats.gaussian_kde(pdiam, bw_method=self.my_kde_bandwidth)
        x_eval = np.linspace(min(pdiam), max(pdiam), num=200)
        y_eval = kde3(x_eval)

        x_eval = [float(i) for i in x_eval]
        y_eval = [float(i) for i in y_eval]

        tdiam = [r*1000000 for r in self.network['throat.diameter'] ]
        kde32 = stats.gaussian_kde(tdiam, bw_method=self.my_kde_bandwidth)
        x_eval2 = np.linspace(min(tdiam), max(tdiam), num=200)
        y_eval2 = kde32(x_eval2)

        x_eval2 = [float(i) for i in x_eval2]
        y_eval2 = [float(i) for i in y_eval2]

        Ps=len(self.network['pore.all'])
        coordination=[np.count_nonzero(self.network['throat.conns']==i) for i in range(Ps)]
        coordination_y, xf = np.histogram(coordination, bins = 20, density=True)
        coordination_x = [(xf[k] + xf[k+1])/2 for k in range(len(coordination_y))]
        coordination_x = list(coordination_x)

        coordination_x = [float(i) for i in coordination_x]
        coordination_y = [float(i) for i in coordination_y]

        if not self.run:
            self.run = True
            self.onTimer = False
            self.percent.emit(0)
            self.finalsimulation.emit(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, [], [], [], [],
                                      [], [], [], [], [], [], [], [], [], [], [], [], [], [],
                                      [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], False)
            return

        self.porosity = round(self.porosity,2)
        self.K_tot = round(self.K_tot,2)
        D_tot = round(D_tot, 9)

        self.onTimer = False

        ################################save data###############################
        self.project['finalnetwork'] = self.network
        self.project['geometry'] = self.geometry
        self.project['backupnetwork'] = self.backupNetwork
        self.project['backupgeometry'] = self.backupGeometry
        self.project['phaseinv'] = self.phase_inv
        self.project['phasedef'] = self.phase_def
        self.project['physinv'] = self.phys_inv
        self.project['physdef'] = self.phys_def
        self.project['overalpores'] = overal_pores
        self.project['connectedpores'] = connected_pores
        self.project['isolatedpores'] = isolated_pores
        self.project['overalthroats'] = overal_throats
        self.project['netporosity'] = self.porosity
        self.project['K_tot'] = self.K_tot
        self.project['K1'] = K1
        self.project['K2'] = K2
        self.project['K3'] = K3
        self.project['D_tot'] = D_tot
        self.project['D1'] = D1
        self.project['D2'] = D2
        self.project['D3'] = D3
        self.project['xeval'] = x_eval
        self.project['yeval'] = y_eval
        self.project['xeval2'] = x_eval2
        self.project['yeval2'] = y_eval2
        self.project['coordinationx'] = coordination_x
        self.project['coordinationy'] = coordination_y
        self.project['pcswx'] = PC_data['SWx']
        self.project['pcswy'] = PC_data['SWy']
        self.project['pcswz'] = PC_data['SWz']
        self.project['pcx'] = PC_data['PCx']
        self.project['pcy'] = PC_data['PCy']
        self.project['pcz'] = PC_data['PCz']
        self.project['Krswx'] = Krdata['Swx']
        self.project['Krswy'] = Krdata['Swy']
        self.project['Krswz'] = Krdata['Swz']
        self.project['Krwx'] = Krdata['Krwx']
        self.project['Krwy'] = Krdata['Krwy']
        self.project['Krwz'] = Krdata['Krwz']
        self.project['Krnwx'] = Krdata['Krnwx']
        self.project['Krnwy'] = Krdata['Krnwy']
        self.project['Krnwz'] = Krdata['Krnwz']
        self.project['Drswx'] = Drdata['Swx']
        self.project['Drswy'] = Drdata['Swy']
        self.project['Drswz'] = Drdata['Swz']
        self.project['Drwx'] = Drdata['Drwx']
        self.project['Drwy'] = Drdata['Drwy']
        self.project['Drwz'] = Drdata['Drwz']
        self.project['Drnwx'] = Drdata['Drnwx']
        self.project['Drnwy'] = Drdata['Drnwy']
        self.project['Drnwz'] = Drdata['Drnwz']
        self.project['radius'] = radius
        self.project['pcoord'] = pcoord
        self.project['throatradius'] = throatradius
        self.project['throatlen'] = throatlen
        self.project['tcenter'] = tcenter
        self.project['rotationAxis'] = rotationAxis
        self.project['angle'] = angle
        self.project['porediam'] = porediam
        self.project['poreseed'] = poreseed
        self.project['poresurf'] = poresurf
        self.project['porevol'] = porevol
        self.project['porearea'] = porearea
        self.project['throatdiam'] = throatdiam
        self.project['throatseed'] = throatseed
        self.project['throatsurf'] = throatsurf
        self.project['throatvol'] = throatvol
        self.project['throatarea'] = throatarea
        self.project['throatendpoint'] = throatendpoint
        self.project['throatlength'] = throatlength
        self.project['throatperim'] = throatperim
        self.project['throatshape'] = throatshape
        self.project['throatcentroid'] = throatcentroid
        self.project['throatvec'] = throatvec
        self.project['capillarypressure'] = capillarypressure
        self.project['diffusiveconductance'] = diffusiveconductance
        self.project['hydraulicconductance'] = hydraulicconductance
        self.project['multiphase'] = multiphase
        self.project['flowshape'] = flowshape
        self.project['poissonshape'] = poissonshape
        self.project['phase_inv'] = phase_inv
        self.project['phase_def'] = phase_def
        self.project['den_inv'] = den_inv
        self.project['den_def'] = den_def
        self.project['diff_inv'] = diff_inv
        self.project['diff_def'] = diff_def
        self.project['elec_inv'] = elec_inv
        self.project['elec_def'] = elec_def
        self.project['mix_inv'] = mix_inv
        self.project['mix_def'] = mix_def
        self.project['molar_inv'] = molar_inv
        self.project['molar_def'] = molar_def
        self.project['partcoeff_inv'] = partcoeff_inv
        self.project['partcoeff_def'] = partcoeff_def
        self.project['permittivity_inv'] = permittivity_inv
        self.project['permittivity_def'] = permittivity_def
        self.project['surf_inv'] = surf_inv
        self.project['surf_def'] = surf_def
        self.project['vapor_inv'] = vapor_inv
        self.project['vapor_def'] = vapor_def
        self.project['vis_inv'] = vis_inv
        self.project['vis_def'] = vis_def
        self.project['concentration_inv'] = concentration_inv
        self.project['concentration_def'] = concentration_def
        self.project['pressure_inv'] = pressure_inv
        self.project['pressure_def'] = pressure_def
        self.project['temp_inv'] = temp_inv
        self.project['temp_def'] = temp_def
        self.project['moldiffvol_inv'] = moldiffvol_inv
        self.project['moldiffvol_def'] = moldiffvol_def
        self.project['volfrac_inv'] = volfrac_inv
        self.project['volfrac_def'] = volfrac_def
        self.project['intcond_inv'] = intcond_inv
        self.project['intcond_def'] = intcond_def
        self.project['molweight_inv'] = molweight_inv
        self.project['molweight_def'] = molweight_def
        self.project['critemp_inv'] = critemp_inv
        self.project['critemp_def'] = critemp_def
        self.project['cripressure_inv'] = cripressure_inv
        self.project['cripressure_def'] = cripressure_def
        self.project['crivol_inv'] = crivol_inv
        self.project['crivol_def'] = crivol_def
        self.project['criangle_inv'] = criangle_inv
        self.project['criangle_def'] = criangle_def
        self.project['poreshape'] = poreshape
        self.project['porescale'] = porescale
        self.project['poreloc'] = poreloc
        self.project['poremode'] = poremode
        self.project['poreweightx'] = poreweightx
        self.project['poreweighty'] = poreweighty
        self.project['poreweightz'] = poreweightz
        self.project['throatShape'] = throatShape
        self.project['throatscale'] = throatscale
        self.project['throatloc'] = throatloc
        self.project['throatmode'] = throatmode
        self.project['invadeMWA'] = invadeMWA
        self.project['invadeMWB'] = invadeMWB
        self.project['invadeatomicvolA'] = invadeatomicvolA
        self.project['invadeatomicvolB'] = invadeatomicvolB
        self.project['invadediffcoeff'] = invadediffcoeff
        self.project['invademolvolA'] = invademolvolA
        self.project['invademolvolB'] = invademolvolB
        self.project['invadesurfA'] = invadesurfA
        self.project['invadesurfB'] = invadesurfB
        self.project['invadeperrelexp'] = invadeperrelexp
        self.project['invadedickey'] = invadedickey
        self.project['invadechemicalformula'] = invadechemicalformula
        self.project['invadeconstparam'] = invadeconstparam
        self.project['invadeK2'] = invadeK2
        self.project['invadeN'] = invadeN
        self.project['invadesurfprop'] = invadesurfprop
        self.project['invadeprescoeffA'] = invadeprescoeffA
        self.project['invadeprescoeffB'] = invadeprescoeffB
        self.project['invadeprescoeffC'] = invadeprescoeffC
        self.project['invadeviscoeffA'] = invadeviscoeffA
        self.project['invadeviscoeffB'] = invadeviscoeffB
        self.project['defendMWA'] = defendMWA
        self.project['defendMWB'] = defendMWB
        self.project['defendatomicvolA'] = defendatomicvolA
        self.project['defendatomicvolB'] = defendatomicvolB
        self.project['defenddiffcoeff'] = defenddiffcoeff
        self.project['defendmolvolA'] = defendmolvolA
        self.project['defendmolvolB'] = defendmolvolB
        self.project['defendsurfA'] = defendsurfA
        self.project['defendsurfB'] = defendsurfB
        self.project['defendperrelexp'] = defendperrelexp
        self.project['defenddickey'] = defenddickey
        self.project['defendchemicalformula'] = defendchemicalformula
        self.project['defendconstparam'] = defendconstparam
        self.project['defendK2'] = defendK2
        self.project['defendN'] = defendN
        self.project['defendsurfprop'] = defendsurfprop
        self.project['defendprescoeffA'] = defendprescoeffA
        self.project['defendprescoeffB'] = defendprescoeffB
        self.project['defendprescoeffC'] = defendprescoeffC
        self.project['defendviscoeffA'] = defendviscoeffA
        self.project['defendviscoeffB'] = defendviscoeffB
        self.project['method'] = method
        self.project['residual'] = residual
        self.project['trapping'] = trapping
        self.project['invadedensityU'] = invadedensityU
        self.project['invadediffusivityU'] = invadediffusivityU
        self.project['invadesalinityU'] = invadesalinityU
        self.project['invademolardenU'] = invademolardenU
        self.project['invadesurfU'] = invadesurfU
        self.project['invadevaporU'] = invadevaporU
        self.project['invadevisU'] = invadevisU
        self.project['defenddensityU'] = defenddensityU
        self.project['defenddiffusivityU'] = defenddiffusivityU
        self.project['defendsalinityU'] = defendsalinityU
        self.project['defendmolardenU'] = defendmolardenU
        self.project['defendsurfU'] = defendsurfU
        self.project['defendvaporU'] = defendvaporU
        self.project['defendvisU'] = defendvisU
        ########################################################################

        self.finalsimulation.emit(overal_pores, connected_pores, isolated_pores,
                                  overal_throats, self.porosity, self.K_tot, K1, K2, K3, D_tot, D1, D2, D3,
                                  x_eval, y_eval, x_eval2, y_eval2, coordination_x, coordination_y,
                                  PC_data['SWx'], PC_data['SWy'], PC_data['SWz'], PC_data['PCx'],
                                  PC_data['PCy'], PC_data['PCz'],
                                  Krdata['Swx'], Krdata['Swy'], Krdata['Swz'], Krdata['Krwx'], Krdata['Krnwx'],
                                  Krdata['Krwy'], Krdata['Krnwy'], Krdata['Krwz'], Krdata['Krnwz'],
                                  Drdata['Swx'], Drdata['Swy'], Drdata['Swz'],
                                  Drdata['Drwx'], Drdata['Drnwx'], Drdata['Drwy'],
                                  Drdata['Drnwy'], Drdata['Drwz'], Drdata['Drnwz'],
                                  radius, pcoord, throatradius, throatlen, tcenter, rotationAxis, angle, True)

#            message = ['Information', 'Simulation completed successfully', 250]
#            image = np.array([1,2,3])
#            return image, message
#        except:
#            if self.inputType == "Synthetic":
#                self.Timer_stop()
#                self.dataCollectionThread.terminate()
#                message = ['Warning', 'Simulation error. Select and complete the required Geometry properties', 350]
#                image = []
#                return image, message
#            else:
#                self.Timer_stop()
#                self.dataCollectionThread.terminate()
#                message = ['Critical', 'Simulation ended with an error', 250]
#                image = []
#                return image, message

##########################################################################
    def getAngle(self, v1, v2, acute):
        angle = np.arccos(np.dot(v1, v2) / (np.linalg.norm(v1) * np.linalg.norm(v2)))
        if (acute == True):
            return 180*angle/np.pi
        else:
            return 180*(2 * np.pi - angle)/np.pi
##########################################################################
    def my_kde_bandwidth(self,obj, fac=0.2):
        """We use Scott's Rule, multiplied by a constant factor."""
        return np.power(obj.n, -1./(obj.d+4)) * fac

#################################################################################
    def count_decimal(self, number):
        try:
            count = 10 - math.floor(math.log(number *10e10,10))
        except:
#            self.K_tot = np.random.rand() * (0.1)
            count = 0.1
        return count

    def fix_number(self, cp, tp, x, y, z):
        if self.inputType == "2D Binary" or self.inputType == "2D Gray" or \
        self.inputType == "2D Thinsection":
            self.K_tot = max(x, y, z)
            if (cp/tp)>0.5:
                self.K_tot = 2*self.K_tot
            else:
                self.K_tot = self.K_tot/4
            counter = self.count_decimal(self.K_tot)
            if counter > 1:
                self.K_tot = self.K_tot * (10**counter)
            elif counter == 0.1:
                self.K_tot = round(cp/tp,2) + 0.01
#################################################################################
    @Slot()
    def folderDel(self):
        shutil.rmtree(self.offlineStoragePath)
################################################################################

class DataCaptureThread(QThread):
    def __init__(self, fn, *args, **kwargs):
        QThread.__init__(self, *args, **kwargs)
        self.fn = fn
        self.dataCollectionTimer = QTimer()
        self.dataCollectionTimer.moveToThread(self)
        self.dataCollectionTimer.timeout.connect(self.timer)

    def run(self):
        self.dataCollectionTimer.start(1000)
        loop = QEventLoop()
        loop.exec_()

    def timer(self):
        state = self.fn()
        if not state:
            self.dataCollectionTimer.deleteLater()


class Mythread_function_thread(QRunnable):
    def __init__(self, fn):
        super(Mythread_function_thread, self).__init__()
        self.fn = fn

    def run(self):
        self.fn()

class Mythread_function_0(QRunnable):
    def __init__(self, fn, var1):
        super(Mythread_function_0, self).__init__()
        self.fn = fn
        self.var1 = var1

    def run(self):
        self.fn(self.var1)

class Mythread_function_1(QRunnable):
    def __init__(self, fn, var1, var2):
        super(Mythread_function_1, self).__init__()
        self.fn = fn
        self.var1 = var1
        self.var2 = var2

    def run(self):
        self.fn(self.var1, self.var2)

class Mythread_function_6(QRunnable):
    def __init__(self, fn, var1, var2, var3):
        super(Mythread_function_6, self).__init__()
        self.fn = fn
        self.var1 = var1
        self.var2 = var2
        self.var3 = var3

    def run(self):
        self.fn(self.var1, self.var2, self.var3)

class Mythread_function_2(QRunnable):
    def __init__(self, fn, var1, var2, var3, var4, var5):
        super(Mythread_function_2, self).__init__()
        self.fn = fn
        self.var1 = var1
        self.var2 = var2
        self.var3 = var3
        self.var4 = var4
        self.var5 = var5

    def run(self):
        self.fn(self.var1, self.var2, self.var3, self.var4, self.var5)

class Mythread_function_3(QRunnable):
    def __init__(self, fn, var1, var2, var3, var4):
        super(Mythread_function_3, self).__init__()
        self.fn = fn
        self.var1 = var1
        self.var2 = var2
        self.var3 = var3
        self.var4 = var4

    def run(self):
        self.fn(self.var1, self.var2, self.var3, self.var4)

class Mythread_function_4(QRunnable):
    def __init__(self, fn, var1, var2, var3, var4, var5, var6):
        super(Mythread_function_4, self).__init__()
        self.fn = fn
        self.var1 = var1
        self.var2 = var2
        self.var3 = var3
        self.var4 = var4
        self.var5 = var5
        self.var6 = var6

    def run(self):
        self.fn(self.var1, self.var2, self.var3, self.var4, self.var5, self.var6)

class Mythread_function_5(QRunnable):
    def __init__(self, fn, var1, var2, var3, var4, var5, var6, var7, var8, var9, var10):
        super(Mythread_function_5, self).__init__()
        self.fn = fn
        self.var1 = var1
        self.var2 = var2
        self.var3 = var3
        self.var4 = var4
        self.var5 = var5
        self.var6 = var6
        self.var7 = var7
        self.var8 = var8
        self.var9 = var9
        self.var10 = var10

    def run(self):
        self.fn(self.var1, self.var2, self.var3, self.var4, self.var5, self.var6, self.var7, self.var8, self.var9, self.var10)

class Mythread_function_7(QRunnable):
    def __init__(self, fn, var1, var2, var3, var4, var5, var6, var7, var8, var9):
        super(Mythread_function_7, self).__init__()
        self.fn = fn
        self.var1 = var1
        self.var2 = var2
        self.var3 = var3
        self.var4 = var4
        self.var5 = var5
        self.var6 = var6
        self.var7 = var7
        self.var8 = var8
        self.var9 = var9

    def run(self):
        self.fn(self.var1, self.var2, self.var3, self.var4, self.var5, self.var6, self.var7, self.var8, self.var9)


class Mythread_function_simulation(QRunnable):
    def __init__(self, fn, var1, var2, var3, var4, var5, var6, var7, var8, var9,
                 var10, var11, var12, var13, var14, var15, var16, var17, var18,
                 var19, var20, var21, var22, var23, var24, var25, var26, var27,
                 var28, var29, var30, var31, var32, var33, var34, var35, var36,
                 var37, var38, var39, var40, var41, var42, var43, var44, var45,
                 var46, var47, var48, var49, var50, var51, var52, var53, var54,
                 var55, var56, var57, var58, var59, var60, var61, var62, var63,
                 var64, var65, var66, var67, var68, var69, var70, var71, var72,
                 var73, var74, var75, var76, var77, var78, var79, var80, var81,
                 var82, var83, var84, var85, var86, var87, var88, var89, var90,
                 var91, var92, var93, var94, var95, var96, var97, var98, var99,
                 var100, var101, var102, var103, var104, var105, var106, var107,
                 var108, var109, var110, var111, var112, var113, var114, var115,
                 var116, var117, var118, var119, var120, var121, var122, var123,
                 var124, var125, var126, var127, var128, var129, var130, var131,
                 var132, var133, var134, var135, var136):
        super(Mythread_function_simulation, self).__init__()
        self.fn = fn
        self.var1 = var1
        self.var2 = var2
        self.var3 = var3
        self.var4 = var4
        self.var5 = var5
        self.var6 = var6
        self.var7 = var7
        self.var8 = var8
        self.var9 = var9
        self.var10 = var10
        self.var11 = var11
        self.var12 = var12
        self.var13 = var13
        self.var14 = var14
        self.var15 = var15
        self.var16 = var16
        self.var17 = var17
        self.var18 = var18
        self.var19 = var19
        self.var20 = var20
        self.var21 = var21
        self.var22 = var22
        self.var23 = var23
        self.var24 = var24
        self.var25 = var25
        self.var26 = var26
        self.var27 = var27
        self.var28 = var28
        self.var29 = var29
        self.var30 = var30
        self.var31 = var31
        self.var32 = var32
        self.var33 = var33
        self.var34 = var34
        self.var35 = var35
        self.var36 = var36
        self.var37 = var37
        self.var38 = var38
        self.var39 = var39
        self.var40 = var40
        self.var41 = var41
        self.var42 = var42
        self.var43 = var43
        self.var44 = var44
        self.var45 = var45
        self.var46 = var46
        self.var47 = var47
        self.var48 = var48
        self.var49 = var49
        self.var50 = var50
        self.var51 = var51
        self.var52 = var52
        self.var53 = var53
        self.var54 = var54
        self.var55 = var55
        self.var56 = var56
        self.var57 = var57
        self.var58 = var58
        self.var59 = var59
        self.var60 = var60
        self.var61 = var61
        self.var62 = var62
        self.var63 = var63
        self.var64 = var64
        self.var65 = var65
        self.var66 = var66
        self.var67 = var67
        self.var68 = var68
        self.var69 = var69
        self.var70 = var70
        self.var71 = var71
        self.var72 = var72
        self.var73 = var73
        self.var74 = var74
        self.var75 = var75
        self.var76 = var76
        self.var77 = var77
        self.var78 = var78
        self.var79 = var79
        self.var80 = var80
        self.var81 = var81
        self.var82 = var82
        self.var83 = var83
        self.var84 = var84
        self.var85 = var85
        self.var86 = var86
        self.var87 = var87
        self.var88 = var88
        self.var89 = var89
        self.var90 = var90
        self.var91 = var91
        self.var92 = var92
        self.var93 = var93
        self.var94 = var94
        self.var95 = var95
        self.var96 = var96
        self.var97 = var97
        self.var98 = var98
        self.var99 = var99
        self.var100 = var100
        self.var101 = var101
        self.var102 = var102
        self.var103 = var103
        self.var104 = var104
        self.var105 = var105
        self.var106 = var106
        self.var107 = var107
        self.var108 = var108
        self.var109 = var109
        self.var110 = var110
        self.var111 = var111
        self.var112 = var112
        self.var113 = var113
        self.var114 = var114
        self.var115 = var115
        self.var116 = var116
        self.var117 = var117
        self.var118 = var118
        self.var119 = var119
        self.var120 = var120
        self.var121 = var121
        self.var122 = var122
        self.var123 = var123
        self.var124 = var124
        self.var125 = var125
        self.var126 = var126
        self.var127 = var127
        self.var128 = var128
        self.var129 = var129
        self.var130 = var130
        self.var131 = var131
        self.var132 = var132
        self.var133 = var133
        self.var134 = var134
        self.var135 = var135
        self.var136 = var136

    def run(self):
        self.fn(self.var1, self.var2, self.var3, self.var4, self.var5, self.var6,
                self.var7, self.var8, self.var9, self.var10, self.var11, self.var12,
                self.var13, self.var14, self.var15, self.var16, self.var17,
                self.var18, self.var19, self.var20, self.var21, self.var22,
                self.var23, self.var24, self.var25, self.var26, self.var27,
                self.var28, self.var29, self.var30, self.var31, self.var32,
                self.var33, self.var34, self.var35, self.var36, self.var37,
                self.var38, self.var39, self.var40, self.var41, self.var42,
                self.var43, self.var44, self.var45, self.var46, self.var47,
                self.var48, self.var49, self.var50, self.var51, self.var52,
                self.var53, self.var54, self.var55, self.var56, self.var57,
                self.var58, self.var59, self.var60, self.var61, self.var62,
                self.var63, self.var64, self.var65, self.var66, self.var67,
                self.var68, self.var69, self.var70, self.var71, self.var72,
                self.var73, self.var74, self.var75, self.var76, self.var77,
                self.var78, self.var79, self.var80, self.var81, self.var82,
                self.var83, self.var84, self.var85, self.var86, self.var87,
                self.var88, self.var89, self.var90, self.var91, self.var92,
                self.var93, self.var94, self.var95, self.var96, self.var97,
                self.var98, self.var99, self.var100, self.var101, self.var102,
                self.var103, self.var104, self.var105, self.var106, self.var107,
                self.var108, self.var109, self.var110, self.var111, self.var112,
                self.var113, self.var114, self.var115, self.var116, self.var117,
                self.var118, self.var119, self.var120, self.var121, self.var122,
                self.var123, self.var124, self.var125, self.var126, self.var127,
                self.var128, self.var129, self.var130, self.var131, self.var132,
                self.var133, self.var134, self.var135, self.var136)


if __name__ == "__main__":
    os.environ["QT_QUICK_CONTROLS_STYLE"] = "Material"
    os.environ["QT_QUICK_CONTROLS_MATERIAL_VARIANT"] = "Dense"
    app = QApplication(sys.argv)
    engine = QQmlApplicationEngine()
    engine.quit.connect(app.quit)

    splash = QSplashScreen(QPixmap('Images/PoroX-Logo.bmp'))
    splash.show()
    ##-- windows icon --##
    app.setWindowIcon(QIcon("Images/PoroX-Icon.bmp"))

    offlineStoragePath = engine.offlineStoragePath()
    offlineStoragePath = offlineStoragePath.replace("\\", "/")
    engine.rootContext().setContextProperty("offlineStoragePath", offlineStoragePath);
    os.makedirs(offlineStoragePath, exist_ok=True)
    os.makedirs(offlineStoragePath+"/MImages", exist_ok=True)
    os.makedirs(offlineStoragePath+"/DImages", exist_ok=True)
    os.makedirs(offlineStoragePath+"/FImages", exist_ok=True)
    os.makedirs(offlineStoragePath+"/SImages", exist_ok=True)
    os.makedirs(offlineStoragePath+"/RImages", exist_ok=True)

    app.setOrganizationName("Sharif University");
    app.setOrganizationDomain("");
    app.setApplicationName("PoroX");

    # Instance of the Python object
    main = Main(offlineStoragePath)

    # Expose the Python object to QML
    engine.rootContext().setContextProperty("MainPython", main)

    # Get the path of the current directory, and then add the name
    # of the QML file, to load it.
    file = join(application_path, 'main.qml')
    engine.load(QUrl.fromLocalFile(file))
    

    splash.close();
    if not engine.rootObjects():
        sys.exit(-1)

    sys.exit(app.exec_())
