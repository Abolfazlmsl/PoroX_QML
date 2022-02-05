import QtQuick 2.14
import QtQuick.Window 2.14
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.12
import QtQuick.Controls.Styles 1.0
import QtDataVisualization 1.0
import QtGraphicalEffects 1.0
import QtQuick.Dialogs 1.3
import QtQuick.Scene3D 2.15
import Qt.labs.platform 1.1
import Qt.labs.settings 1.1

import "./Modules"
import "./Fonts/Icon.js" as Icons

Window {
    id: main1

    visible: true
    width: Screen.width*0.85
    height: Screen.height*0.85
    title: qsTr("PoroX")

    //-- save app setting --//
    property var setting: Settings{
        id: setting

        //license properties
        property bool isLicensed: false
        property string username: ""
        property string password: ""
        property string token_access: ""
        property string token_refresh: ""
        property bool   isRemember

    }

    property bool isLicensed: false
    signal showLogin()
    signal showTrial()
    signal showPurchase()

    onShowLogin: {
        licenseform.visible = true
        trialform.visible = false
        purchaseform.visible = false
    }

    onShowTrial: {
        licenseform.visible = false
        trialform.visible = true
        purchaseform.visible = false
    }

    onShowPurchase: {
        licenseform.visible = false
        trialform.visible = false
        purchaseform.visible = true
    }

    Component.onCompleted: {
        x = Screen.width / 2 - width / 2
        y = Screen.height / 2 - height / 2
        MainPython.time.connect(getTimer)
        MainPython.percent.connect(getPercent)
        MainPython.stopButton.connect(changeStopButton)
        MainPython.openFile.connect(getOpenfile)
        MainPython.saveFile.connect(getSaveFileSignal)
        MainPython.newFile.connect(getNewFileSignal)
    }

    signal getNewFileSignal()
    onGetNewFileSignal: {
        xdim = 0
        ydim = 0
        zdim = 1

        swipTitle = "Data"
        section1.checked = true
        sView.currentIndex = 0
        resultview.sResultview = 0

        sceneset.segmentVisible = false
        sceneset.reconstructVisible = false
        sceneset.poreVisible = false
        sceneset.throatVisible = false
        sceneset.source1 = ""
        sceneset.source2 = ""

        savePath = ""

        inputdata = ""
        isGray = true

        inputType = ""

        denoiseItem.method = "Gaussian"
        denoiseItem.denoiseparam = "2"
        filterItem.method = "Bilateral"
        filterItem.state = "Bilateral"
        filterItem.filterparam1 = "2"
        filterItem.filterparam2 = "3"
        filterItem.filterparam3 = "3"
        filterItem.filterparam4 = ""
        segmentationItem.method = "Otsu"
        segmentationItem.state = "Otsu"
        segmentationItem.segmentParam = 0
        totalPorosity = 0
        xdimReconstruct = 0
        ydimReconstruct = 0
        zdimReconstruct = 0
        statisticalItem.cutoff = 4
        mpsItem.tempx = "10"
        mpsItem.tempy = "10"
        mpsItem.tempz = "10"
        snowItem.rprop = "4"
        snowItem.sprop = "0.4"
        maximalballItem.minRprop = ""

        poreItem.porediamcheck = false
        poreItem.porediamstate = "From-neighbor-throats"
        poreItem.changeporediam("1.5", "0.000001", "0", "min")

        poreItem.poreseedcheck = false
        poreItem.poreseedstate = "Random"
        poreItem.changeporeseed("2", "2", "2")

        poreItem.poresurfcheck = false
        poreItem.poresurfstate = "Sphere"

        poreItem.porevolcheck = false
        poreItem.porevolstate = "Sphere"

        poreItem.poreareacheck = false
        poreItem.poreareastate = "Sphere"

        throatItem.throatdiamcheck = false
        throatItem.throatdiamstate = "From_neighbor_pores"
        throatItem.changethroatdiam("1.5", "0.000001", "0", "min")

        throatItem.throatseedcheck = false
        throatItem.throatseedstate = "Random"

        throatItem.throatsurfcheck = false
        throatItem.throatsurfstate = "Cylinder"

        throatItem.throatvolcheck = false
        throatItem.throatvolstate = "Cylinder"

        throatItem.throatareacheck = false
        throatItem.throatareastate = "Cylinder"

        throatItem.throatendcheck = false
        throatItem.throatendstate = "Spherical_pores"

        throatItem.throatlencheck = false
        throatItem.throatlenstate = "ctc"

        throatItem.throatpericheck = false
        throatItem.throatperistate = "Cylinder"
        throatItem.throatshapecheck = false
        throatItem.throatshapestate = "Compactness"

        physicItem.pccheck = false
        physicItem.pcstate = "Washburn"

        physicItem.diffcondcheck = false
        physicItem.diffcondstate = "Mixed_diffusion"

        physicItem.hydcondcheck = false
        physicItem.hydcondstate = "Hagen_poiseuille"

        physicItem.multicheck = false
        physicItem.multistate = "Conduit_conductance"

        physicItem.flowshapecheck = false
        physicItem.flowshapestate = "Ball_and_stick"

        physicItem.poissonshapecheck = false
        physicItem.poissonshapestate = "Ball_and_stick"

        invadingItem.dencheck = false
        invadingItem.denstate = "Water"
        invadingItem.denuser = ""

        invadingItem.diffcheck = false
        invadingItem.diffstate = "Fuller"
        invadingItem.changediff("", "", "", "", "", "", "", "", "")
        invadingItem.diffuser = ""

        invadingItem.eleccheck = false
        invadingItem.changeelec("")

        invadingItem.mixcheck = false
        invadingItem.mixstate = "Salinity"
        invadingItem.changemixture("")
        invadingItem.mixuser = ""

        invadingItem.molardencheck = false
        invadingItem.molardenstate = "Standard"
        invadingItem.molaruser = ""

        invadingItem.partcoeffcheck = true
        invadingItem.changepartcoeff("")

        invadingItem.pericheck = true

        invadingItem.surfcheck = false
        invadingItem.surfstate = "Water"
        invadingItem.changesurf("", "", "", "")
        invadingItem.surfuser = ""

        invadingItem.vaporcheck = false
        invadingItem.vaporstate = "Water"
        invadingItem.changevapor("", "", "")
        invadingItem.vaporuser = ""

        invadingItem.vischeck = false
        invadingItem.visstate = "Water"
        invadingItem.changevis("", "")
        invadingItem.visuser = ""

        invadingItem.concen = ""
        invadingItem.press = ""
        invadingItem.temp = ""
        invadingItem.volfrac = ""
        invadingItem.intrinsic = ""
        invadingItem.mw = ""
        invadingItem.critemp = ""
        invadingItem.cripressure = ""
        invadingItem.crivol = ""
        invadingItem.criangle = ""

        defendingItem.dencheck = false
        defendingItem.denstate = "Water"
        defendingItem.denuser = ""

        defendingItem.diffcheck = false
        defendingItem.diffstate = "Fuller"
        defendingItem.changediff("", "", "", "", "", "", "", "", "")
        defendingItem.diffuser = ""

        defendingItem.eleccheck = false
        defendingItem.changeelec("")

        defendingItem.mixcheck = false
        defendingItem.mixstate = "Salinity"
        defendingItem.changemixture("")
        defendingItem.mixuser = ""

        defendingItem.molardencheck = false
        defendingItem.molardenstate = "Standard"
        defendingItem.molaruser = ""

        defendingItem.partcoeffcheck = true
        defendingItem.changepartcoeff("")

        defendingItem.pericheck = true

        defendingItem.surfcheck = false
        defendingItem.surfstate = "Water"
        defendingItem.changesurf("", "", "", "")
        defendingItem.surfuser = ""

        defendingItem.vaporcheck = false
        defendingItem.vaporstate = "Water"
        defendingItem.changevapor("", "", "")
        defendingItem.vaporuser = ""

        defendingItem.vischeck = false
        defendingItem.visstate = "Water"
        defendingItem.changevis("", "")
        defendingItem.visuser = ""

        defendingItem.concen = ""
        defendingItem.press = ""
        defendingItem.temp = ""
        defendingItem.volfrac = ""
        defendingItem.intrinsic =""
        defendingItem.mw = ""
        defendingItem.critemp = ""
        defendingItem.cripressure = ""
        defendingItem.crivol = ""
        defendingItem.criangle = ""

        main1.phase_inv = "Air"
        main1.phase_def = "Water"

        simulationItem.method = "Ordinary Percolation"
        simulationItem.simulationstate = "Ordinary Percolation"
        simulationItem.rescheck = false
        simulationItem.resvalue = ""
        simulationItem.trapcheck = false
        simulationItem.trapping = false

        porexData = []
        poreyData = []
        grainxData = []
        grainyData = []
        s2_x = []
        s2_y = []
        psdxData = []
        psdyData = []
        tsdxData = []
        tsdyData = []
        coordxData = []
        coordyData = []
        pcswxData = []
        pcxData = []
        pcswyData = []
        pcyData = []
        pcswzData = []
        pczData = []

        krswxData = []
        krswyData = []
        krswzData = []
        krwxData = []
        krnwxData = []
        krwyData = []
        krnwyData = []
        krwzData = []
        krnwzData = []

        drswxData = []
        drswyData = []
        drswzData = []
        drwxData = []
        drnwxData = []
        drwyData = []
        drnwyData = []
        drwzData = []
        drnwzData = []

        psdchart.plot()
        gsdchart.plot()
        s2chart.plot()
        psdnet.plot()
        tsdnet.plot()
        coordchart.plot()
        pcchart.plot()
        krchart.plot()
        drchart.plot()

        porediam = false
        porediamType = ""
        poreseed = false
        poreseedType = ""
        poresurf = false
        poresurfType = ""
        porevol = false
        porevolType = ""
        porearea = false
        poreareaType = ""
        throatdiam = false
        throatdiamType = ""
        throatseed = false
        throatseedType = ""
        throatsurf = false
        throatsurfType = ""
        throatvol = false
        throatvolType = ""
        throatarea = false
        throatareaType = ""
        throatendpoint = false
        throatendpointType = ""
        throatlength = false
        throatlengthType = ""
        throatperim = false
        throatperimType = ""
        throatshapefactor = false
        throatshapefactorType = ""
        throatcentroid = true
        throatvector = true
        capillarypressure = true
        capillarypressureType = "Washburn"
        diffusivecond = true
        diffusivecondType = "Mixed_diffusion"
        hydrauliccond = true
        hydrauliccondType = "Hagen_poiseuille"
        multiphase = false
        multiphaseType = "Conduit_conductance"
        flowshapefactor = false
        flowshapefactorType = ""
        poissonshapefactor = true
        poissonshapefactorType = "Ball_and_stick"
        invadedensity = false
        invadedensityType = ""
        defenddensity = false
        defenddensityType = ""
        invadediffusivity = false
        invadediffusivityType = ""
        defenddiffusivity = false
        defenddiffusivityType = ""
        invadeelectrical = false
        defendelectrical = false
        invademixture = false
        invademixtureType = ""
        defendmixture = false
        defendmixtureType = ""
        invademolar = false
        invademolarType = ""
        defendmolar = false
        defendmolarType = ""
        invadepartcoeff = false
        defendpartcoeff = false
        invadepermittivity = false
        defendpermittivity = false
        invadesurf = false
        invadesurfType = ""
        defendsurf = false
        defendsurfType = ""
        invadevapor = false
        invadevaporType = ""
        defendvapor = false
        defendvaporType = ""
        invadeviscosity = false
        invadeviscosityType = ""
        defendviscosity = false
        defendviscosityType = ""

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

        invadeconcentration = ""
        defendconcentration = ""
        invadepressure = ""
        defendpressure = ""
        invadetemp = ""
        defendtemp = ""
        invademoldiffvol = ""
        defendmoldiffvol = ""
        invadevolfrac = ""
        defendvolfrac = ""
        invadeintcond = ""
        defendintcond = ""
        invademolweight = ""
        defendmolweight = ""
        invadecritemp = ""
        defendcritemp = ""
        invadecripressure = ""
        defendcripressure = ""
        invadecrivol = ""
        defendcrivol = ""
        invadecriangle = ""
        defendcriangle = ""

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

        psdImage = false
        gsdImage = false
        s2 = false
        psdnetwork = false
        tsdnetwork = false
        coord = false
        cp = false
        kr = false
        dr = false

        network = false
        geometry = false

        phys_inv = ""
        phys_def = ""
        phase_inv = "Air"
        phase_def = "Water"

        main_image = false
        denoise_image = false
        filter_image = false
        segment_image = false
        reconstruct_image = false

        sceneModel.clear()
        scene2dModel.clear()
        networkmodel.clear()
        geometrymodel.clear()
        tablemodel.clear()
        resultmodel.clear()
        inputmodel.clear()
        imagehandlemodel.clear()
        reconstructmodel.clear()
        phaseinvmodel.clear()
        phasedefmodel.clear()
        physicmodel.clear()
        physicmodel.append({
                           "maintext": "Capillary pressure",
                           "proptext": "Capillary pressure (Weibull)"
                           })
        physicmodel.append({
                           "maintext": "Diffusive conductance",
                           "proptext": "Diffusive conductance (Mixed_diffusion)"
                           })
        physicmodel.append({
                           "maintext": "Hydraulic conductance",
                           "proptext": "Hydraulic conductance (Hagen_poiseuille)"
                           })
        physicmodel.append({
                           "maintext": "Multiphase",
                           "proptext": "Multiphase (Conduit_conductance)"
                           })
        physicmodel.append({
                           "maintext": "Poisson shape factor",
                           "proptext": "Poisson shape factor (Ball_and_stick)"
                           })


        poreprops.clear()
        throatprops.clear()

        cubicItem.xdimcon = 5
        cubicItem.ydimcon = 5
        cubicItem.zdimcon = 5
        cubicItem.xspacon = 0.000001
        cubicItem.yspacon = 0.000001
        cubicItem.zspacon = 0.000001
        cubicItem.ccon = 6
        cubicdualItem.xdimcon = 5
        cubicdualItem.ydimcon = 5
        cubicdualItem.zdimcon = 5
        cubicdualItem.spacon = 0.000001
        braivasItem.xdimcon = 5
        braivasItem.ydimcon = 5
        braivasItem.zdimcon = 5
        braivasItem.spacon = 0.000001
        braivasItem.netstate = "sc"
        braivasItem.netMode = "sc"
        delaunayvoronoidualItem.xdimcon = 5
        delaunayvoronoidualItem.ydimcon = 5
        delaunayvoronoidualItem.zdimcon = 5
        delaunayvoronoidualItem.pointnum = 100
        delaunayItem.xdimcon = 5
        delaunayItem.ydimcon = 5
        delaunayItem.zdimcon = 5
        delaunayItem.pointnum = 100
        voronoiItem.xdimcon = 5
        voronoiItem.ydimcon = 5
        voronoiItem.zdimcon = 5
        voronoiItem.pointnum = 100
        gabrielItem.xdimcon = 5
        gabrielItem.ydimcon = 5
        gabrielItem.zdimcon = 5
        gabrielItem.pointnum = 100

        savePath = ""
        filepanel.saveEnable = false

        leftfilepanel.restart()
        successDynamicPop.messageText = "New file started successfully"
        animationdynamicpop.restart()
    }

    signal getSaveFileSignal()
    onGetSaveFileSignal: {
        filepanel.saveEnable = false
        leftfilepanel.restart()
        successDynamicPop.messageText = "File saved successfully"
        animationdynamicpop.restart()
    }

    Shortcut{
        sequence: "Ctrl+S"
        onActivated: {
            if (filepanel.saveEnable){
                if (savePath === ""){
                    fileSave.visible = true
                }else{
                    MainPython.save_file(savePath)
                }
            }
        }
    }

    Shortcut{
        sequence: "Ctrl+O"
        onActivated: {
            fileOpen.visible = true
        }
    }

    Shortcut{
        sequence: "Ctrl+N"
        onActivated: {
            newfilePop.visible = true
        }
    }

    signal getOpenfile(var type, var xDim, var yDim, var zDim, var res,
                       var porosity, var xData, var yData, var gxData, var gyData,
                       var denoiseMethod, var denoiseParam, var filterMethod, var filterParam1,
                       var filterParam2, var filterParam3, var filterParam4, var segmentMethod,
                       var th, var reconstructMethod, var rporosity, var rparam1, var rparam2, var rparam3, var rparam4,
                       var rparam5, var rparam6, var s2x, var s2y, var extractionMethod,
                       var extractionparam1, var extractionparam2,
                       var overal_pores, var connected_pores, var isolated_pores,
                       var overal_throats, var porosity, var K_tot, var K1, var K2, var K3, var D_tot, var D1, var D2, var D3,
                       var x_eval, var y_eval, var x_eval2, var y_eval2, var coordinationx, var coordinationy,
                       var PCswx, var PCswy, var PCswz, var PCpcx, var PCpcy, var PCpcz,
                       var Krswx, var Krswy, var Krswz, var Krwx, var Krnwx,
                       var Krwy, var Krnwy, var Krwz, var Krnwz,
                       var Drswx, var Drswy, var Drswz, var Drwx, var Drnwx, var Drwy,
                       var Drnwy, var Drwz, var Drnwz, var poreradius, var porecoord,
                       var throatradius, var throatlen, var throatcen, var rotation, var angle,
                       var porediam, var poreseed, var poresurf, var porevol, var porearea,
                       var throatdiam, var throatseed, var throatsurf, var throatvol, var throatarea,
					   var throatendpoint, var throatlength, var throatperim, var throatshape,
					   var throatcentroid, var throatvec, var capillarypressure, var diffusiveconductance, 
					   var hydraulicconductance, var multiphase, var flowshape, var poissonshape, 
					   var phase_inv, var phase_def, var den_inv, var den_def, var diff_inv, var diff_def,
					   var elec_inv, var elec_def, var mix_inv, var mix_def, var molar_inv, var molar_def,
					   var partcoeff_inv, var partcoeff_def, var permittivity_inv, var permittivity_def, var surf_inv,
					   var surf_def, var vapor_inv, var vapor_def, var vis_inv, var vis_def, var concentration_inv,
					   var concentration_def, var pressure_inv, var pressure_def, var temp_inv, var temp_def,
					   var moldiffvol_inv, var moldiffvol_def, var volfrac_inv, var volfrac_def, var intcond_inv, 
					   var intcond_def, var molweight_inv, var molweight_def, var critemp_inv, var critemp_def,
					   var cripressure_inv, var cripressure_def, var crivol_inv, var crivol_def, var criangle_inv, 
					   var criangle_def, var poreshape, var porescale, var poreloc, var poremode, var poreweightx, 
					   var poreweighty, var poreweightz, var throatShape, var throatscale, var throatloc, 
					   var throatmode, var invadeMWA, var invadeMWB, var invadeatomicvolA, var invadeatomicvolB,
					   var invadediffcoeff, var invademolvolA, var invademolvolB, var invadesurfA, var invadesurfB,
					   var invadeperrelexp, var invadedickey, var invadechemicalformula, var invadeconstparam,
					   var invadeK2, var invadeN, var invadesurfprop, var invadeprescoeffA, var invadeprescoeffB,
					   var invadeprescoeffC, var invadeviscoeffA, var invadeviscoeffB, var defendMWA, var defendMWB,
					   var defendatomicvolA, var defendatomicvolB, var defenddiffcoeff, var defendmolvolA,
					   var defendmolvolB, var defendsurfA, var defendsurfB, var defendperrelexp, var defenddickey,
					   var defendchemicalformula, var defendconstparam, var defendK2, var defendN, var defendsurfprop, 
					   var defendprescoeffA, var defendprescoeffB, var defendprescoeffC, var defendviscoeffA,
					   var defendviscoeffB, var method, var residual, var trapping, var invadedensityU, var invadediffusivityU,
					   var invadesalinityU, var invademolardenU, var invadesurfU, var invadevaporU, var invadevisU, 
					   var defenddensityU, var defenddiffusivityU, var defendsalinityU, var defendmolardenU, 
                       var defendsurfU, var defendvaporU, var defendvisU, var constructMode, var xspa, var yspa,
                       var zspa, var connect, var nump, var mode)

    onGetOpenfile: {
        // -- Main Image -- //
        inputdata = type
        inputType = type

        if (inputdata === "Synthetic Network"){
            if (constructMode === "Cubic"){
                cubicItem.xdimcon = parseInt(xDim / xspa)
                cubicItem.ydimcon = parseInt(yDim / yspa)
                cubicItem.zdimcon = parseInt(zDim / zspa)
                cubicItem.xspacon = xspa
                cubicItem.yspacon = yspa
                cubicItem.zspacon = zspa
                cubicItem.ccon = connect
            }else if (constructMode === "CubicDual"){
                cubicdualItem.xdimcon = parseInt(xDim / xspa)
                cubicdualItem.ydimcon = parseInt(yDim / xspa)
                cubicdualItem.zdimcon = parseInt(zDim / xspa)
                cubicdualItem.spacon = xspa
            }else if (constructMode === "Bravais"){
                braivasItem.xdimcon = parseInt(xDim / xspa)
                braivasItem.ydimcon = parseInt(yDim / xspa)
                braivasItem.zdimcon = parseInt(zDim / xspa)
                braivasItem.spacon = xspa
                braivasItem.netstate = mode
                braivasItem.netMode = mode
            }else if (constructMode === "DelaunayVoronoiDual"){
                delaunayvoronoidualItem.xdimcon = parseInt(xDim / 1e-6)
                delaunayvoronoidualItem.ydimcon = parseInt(yDim / 1e-6)
                delaunayvoronoidualItem.zdimcon = parseInt(zDim / 1e-6)
                delaunayvoronoidualItem.pointnum = nump
            }else if (constructMode === "Delaunay"){
                delaunayItem.xdimcon = parseInt(xDim / 1e-6)
                delaunayItem.ydimcon = parseInt(yDim / 1e-6)
                delaunayItem.zdimcon = parseInt(zDim / 1e-6)
                delaunayItem.pointnum = nump
            }else if (constructMode === "Voronoi"){
                voronoiItem.xdimcon = parseInt(xDim / 1e-6)
                voronoiItem.ydimcon = parseInt(yDim / 1e-6)
                voronoiItem.zdimcon = parseInt(zDim / 1e-6)
                voronoiItem.pointnum = nump
            }else if (constructMode === "Gabriel"){
                gabrielItem.xdimcon = parseInt(xDim / 1e-6)
                gabrielItem.ydimcon = parseInt(yDim / 1e-6)
                gabrielItem.zdimcon = parseInt(zDim / 1e-6)
                gabrielItem.pointnum = nump
            }

            xdim = (xDim)*1000000
            ydim = (yDim)*1000000
            zdim = (zDim)*1000000

            sceneset.z = (zDim)*1000000 - 200

            sceneset.segmentVisible = false
            sceneset.reconstructVisible = false
            sceneset.throatVisible = true
            sceneset.poreVisible = true
            if (method === ""){
                poreprops.clear()
                for (var i=0; i<porecoord.length; i++){
                    poreprops.append(
                                {
                                    "Radi": (0.3*xspa)*1000000/3,
                                    "Coordx": porecoord[i][0]* 1000000,
                                    "Coordy": porecoord[i][1]* 1000000,
                                    "Coordz": porecoord[i][2]* 1000000
                                }
                                )
                }

                throatprops.clear()
                for (i=0; i<throatlen.length; i++){
                    throatprops.append(
                                {
                                    "Radi": (0.2*xspa)*1000000/4/3,
                                    "Length": throatlen[i]* 1000000,
                                    "Centerx": throatcen[i][0]* 1000000,
                                    "Centery": throatcen[i][1]* 1000000,
                                    "Centerz": throatcen[i][2]* 1000000,
                                    "Rotatex": rotation[i][0],
                                    "Rotatey": rotation[i][1],
                                    "Rotatez": rotation[i][2],
                                    "Angle": angle[i]
                                }
                                )
                }

                sceneset.segmentVisible = false
                sceneset.reconstructVisible = false
                for (var j=0; j<sceneModel.count; j++){
                    if (sceneModel.get(j).name !== "3D Network"){
                        sceneModel.setProperty(j, "state", false)
                    }
                }

                if (!findbyNameBool(sceneModel, "3D Network")){
                    sceneModel.append(
                                {
                                    "name":"3D Network",
                                    "state": true
                                }
                                )
                }
            }

            networkmodel.clear()
            networkmodel.append({
                                    "maintext": "Construct (Cubic)",
                                    "proptext": "X:" + xDim + " Y:" + yDim + " Z:" + zDim
                                })
            network = true

        }else{
            if (inputdata === "3D Binary" || inputdata === "2D Binary"){
                porexData = xData
                poreyData = yData
                psdchart.plot()

                grainxData = gxData
                grainyData = gyData
                gsdchart.plot()

                totalPorosity = porosity
                resultmodel.clear()
                resultmodel.append({
                                       "text": "Porosity (Original image): " + porosity + "%"
                                   })
                isGray = false
            }

            xdim = xDim
            ydim = yDim
            zdim = zDim
            resolution = res
            swipTitle = "Input"
            section1.checked = true
            sView.currentIndex = 1
            inputmodel.clear()
            inputmodel.append({
                                  "maintext": inputdata,
                                  "proptext": "X:" + xDim + ", Y:" + yDim + ", Z:" + zDim
                              })
            if (inputdata === "3D Binary" || inputdata === "3D Gray"){
                sceneset.source1 = "file:///" + offlineStoragePath + "/main.stl"
            }else{
                sceneset.source1 = "file:///" + offlineStoragePath + "/MImages/M0001.png"
            }
            sceneset.segmentVisible = true

            sceneModel.append(
                        {
                            "name":"3D Segment",
                            "state": true
                        }
                        )
            scene2dModel.append(
                        {
                            "name":"2D Image",
                            "state": false
                        }
                        )
            main_image = true

            // -- Denoise Image -- //
            if (denoiseMethod !== ""){
                denoiseItem.method = denoiseMethod
                denoiseItem.denoiseparam = denoiseParam

                if (denoiseMethod === "Gaussian" || denoiseMethod === "Gaussian-Laplace"){
                    imagehandlemodel.append({
                                                "maintext": "Denoise",
                                                "proptext": denoiseMethod + " (Sigma:" + denoiseParam + ")"
                                            })
                }else if (denoiseMethod === "Minimum" || denoiseMethod === "Maximum" ||
                          denoiseMethod === "Median" || denoiseMethod === "Rank"){
                    imagehandlemodel.append({
                                                "maintext": "Denoise",
                                                "proptext": denoiseMethod + " (Size:" + denoiseParam + ")"
                                            })
                }else{
                    imagehandlemodel.append({
                                                "maintext": "Denoise",
                                                "proptext": denoiseMethod,
                                            })
                }

                if (!findbyName(scene2dModel, "2D Denoise")){
                    scene2dModel.append(
                                {
                                    "name":"2D Denoise",
                                    "state": false
                                }
                                )
                }

                denoise_image = true
            }

            // -- Filter Image -- //
            if (filterMethod !== ""){
                filterItem.method = filterMethod
                filterItem.state = filterMethod
                filterItem.filterparam1 = filterParam1
                filterItem.filterparam2 = filterParam2
                filterItem.filterparam3 = filterParam3
                filterItem.filterparam4 = filterParam4

                if (filterMethod === "Bilateral"){
                    imagehandlemodel.append({
                                                "maintext": "Filter" + " (" + filterMethod + ")",
                                                "proptext": "d:" + filterParam1 + ", sigmaColor:" + filterParam2 + ", sigmaSpace:" + filterParam3
                                            })
                }else if (filterMethod === "Bilateral Modified"){
                    imagehandlemodel.append({
                                                "maintext": "Filter" + " (" + filterMethod + ")",
                                                "proptext": "sigam_s:" + filterParam1 + ", sigma_v:" + filterParam2
                                            })
                }else if (filterMethod === "Averaging"){
                    imagehandlemodel.append({
                                                "maintext": "Filter" + " (" + filterMethod + ")",
                                                "proptext": "kernel:" + filterParam1
                                            })
                }else if (filterMethod === "Smoothing"){
                    imagehandlemodel.append({
                                                "maintext": "Filter" + " (" + filterMethod + ")",
                                                "proptext": "ksizeArg1:" + filterParam1 + ", ksizeArg2:" + filterParam2
                                            })
                }else if (filterMethod === "Gaussian"){
                    imagehandlemodel.append({
                                                "maintext": "Filter" + " (" + filterMethod + ")",
                                                "proptext": "ksizeArg1:" + filterParam1 + ", ksizeArg2:" + filterParam2 + ", sigmaX:" + filterParam3 + ", sigmaY:" + filterParam4
                                            })
                }else if (filterMethod === "Median"){
                    imagehandlemodel.append({
                                                "maintext": "Filter" + " (" + filterMethod + ")",
                                                "proptext": "size:" + filterParam1
                                            })
                }

                if (!findbyName(scene2dModel, "2D Filter")){
                    scene2dModel.append(
                                {
                                    "name":"2D Filter",
                                    "state": false
                                }
                                )
                }

                filter_image = true
            }

            // -- Segment Image -- //
            if (segmentMethod !== ""){
                porexData = xData
                poreyData = yData
                psdchart.plot()
                grainxData = gxData
                grainyData = gyData
                gsdchart.plot()
                segmentationItem.method = segmentMethod
                segmentationItem.state = segmentMethod
                segmentationItem.segmentParam = th
                totalPorosity = porosity
                tablemodel.append({
                                      "method": segmentMethod,
                                      "threshold": th,
                                      "porosity": porosity
                                  })

                imagehandlemodel.append({
                                            "maintext": "Segment",
                                            "proptext": segmentMethod + " (Threshold:" + th + ")",
                                        })

                sceneset.source1 = ""
                sceneset.source1 = "file:///" + offlineStoragePath + "/main.stl"

                if (!findbyNameBool(scene2dModel, "2D Segment")){
                    scene2dModel.append(
                                {
                                    "name":"2D Segment",
                                    "state": false
                                }
                                )
                }
                resultview.sResultview = 1
                segment_image = true
            }

            // -- Reconstruct Image -- //
            if (reconstructMethod !== ""){
                if (reconstructMethod === "Statistical"){
                    s2_x = s2x
                    s2_y = s2y
                    s2chart.plot()

                    xdimReconstruct = rparam1
                    ydimReconstruct = rparam2
                    zdimReconstruct = rparam3
                    statisticalItem.cutoff = rparam4
                    reconstructmodel.clear()
                    reconstructmodel.append({
                                                "maintext": "Reconstruct (Statistical)",
                                                "proptext": "X:" + xdimReconstruct + " Y:" + ydimReconstruct + " Z:" + zdimReconstruct
                                            })

                    resultmodel.append({
                                           "text": "Porosity (Reconstructed image): " + rporosity + "%",
                                       })

                    sceneset.segmentVisible = false
                    sceneset.throatVisible = false
                    sceneset.poreVisible = false
                    sceneset.reconstructVisible = true
                    sceneset.source2 = ""
                    sceneset.source2 = "file:///" + offlineStoragePath + "/reconstruct.stl"
                    for (var j=0; j<sceneModel.count; j++){
                        if (sceneModel.get(j).name !== "3D Reconstruct"){
                            sceneModel.setProperty(j, "state", false)
                        }else{
                            sceneModel.setProperty(j, "state", true)
                        }
                    }

                    if (!findbyNameBool(sceneModel, "3D Reconstruct")){
                        sceneModel.append(
                                    {
                                        "name":"3D Reconstruct",
                                        "state": true
                                    }
                                    )
                    }

                    if (!findbyNameBool(scene2dModel, "2D Reconstruct")){
                        scene2dModel.append(
                                    {
                                        "name":"2D Reconstruct",
                                        "state": false
                                    }
                                    )
                    }
                    reconstruct_image = true
                }else{
                    xdimReconstruct = rparam1
                    ydimReconstruct = rparam2
                    zdimReconstruct = rparam3
                    mpsItem.tempx = rparam4
                    mpsItem.tempy = rparam5
                    mpsItem.tempz = rparam6
                    reconstructmodel.clear()
                    reconstructmodel.append({
                                                "maintext": "Reconstruct (MPS)",
                                                "proptext": "X:" + xdimReconstruct + " Y:" + ydimReconstruct + " Z:" + zdimReconstruct
                                            })

                    resultmodel.append({
                                           "text": "Porosity (Reconstructed image): " + rporosity + "%",
                                       })

                    sceneset.segmentVisible = false
                    sceneset.throatVisible = false
                    sceneset.poreVisible = false
                    sceneset.reconstructVisible = true
                    sceneset.source2 = ""
                    sceneset.source2 = "file:///" + offlineStoragePath + "/reconstruct.stl"
                    for (var j=0; j<sceneModel.count; j++){
                        if (sceneModel.get(j).name !== "3D Reconstruct"){
                            sceneModel.setProperty(j, "state", false)
                        }else{
                            sceneModel.setProperty(j, "state", true)
                        }
                    }

                    if (!findbyNameBool(sceneModel, "3D Reconstruct")){
                        sceneModel.append(
                                    {
                                        "name":"3D Reconstruct",
                                        "state": true
                                    }
                                    )
                    }

                    if (!findbyNameBool(scene2dModel, "2D Reconstruct")){
                        scene2dModel.append(
                                    {
                                        "name":"2D Reconstruct",
                                        "state": false
                                    }
                                    )
                    }
                    reconstruct_image = true
                }
            }

            // -- Extraction -- //
            if (extractionMethod !== ""){
                if (extractionMethod === "SNOW"){
                    snowItem.rprop = extractionparam1
                    snowItem.sprop = extractionparam2
                    networkmodel.clear()
                    networkmodel.append({
                                            "maintext": "Extract (SNOW)",
                                            "proptext": "R_max:" + extractionparam1 + " Sigma:" + extractionparam2
                                        })

                    network = true
                }else{
                    maximalballItem.minRprop = extractionparam1
                    networkmodel.clear()
                    networkmodel.append({
                                            "maintext": "Extract (Maximal Ball)",
                                            "proptext": "Minimum pore radius:" + extractionparam1
                                        })

                    network = true
                }
            }
        }
        if (method !== ""){

            if (porediam !== ""){
                poreItem.porediamcheck = true
                poreItem.porediamstate = porediam
                porediamType = porediam
                poreItem.changeporediam(poreshape, porescale, poreloc, poremode)
            }

            if (poreseed !== ""){
                poreItem.poreseedcheck = true
                poreItem.poreseedstate = poreseed
                poreseedType = poreseed
                poreItem.changeporeseed(poreweightx, poreweighty, poreweightz)
            }

            if (poresurf !== ""){
                poreItem.poresurfcheck = true
                poreItem.poresurfstate = poresurf
                poresurfType = poresurf
            }
            if (porevol !== ""){
                poreItem.porevolcheck = true
                poreItem.porevolstate = porevol
                porevolType = porevol
            }
            if (porearea !== ""){
                poreItem.poreareacheck = true
                poreItem.poreareastate = porearea
                poreareaType = porearea
            }
            if (throatdiam !== ""){
                throatItem.throatdiamcheck = true
                throatItem.throatdiamstate = throatdiam
                throatdiamType = throatdiam
                throatItem.changethroatdiam(throatShape, throatscale, throatloc, throatmode)
            }
            if (throatseed !== ""){
                throatItem.throatseedcheck = true
                throatItem.throatseedstate = throatseed
                throatseedType = throatseed
            }

            if (throatsurf !== ""){
                throatItem.throatsurfcheck = true
                throatItem.throatsurfstate = throatsurf
                throatsurfType = throatsurf
            }
            if (throatvol !== ""){
                throatItem.throatvolcheck = true
                throatItem.throatvolstate = throatvol
                throatvolType = throatvol
            }
            if (throatarea !== ""){
                throatItem.throatareacheck = true
                throatItem.throatareastate = throatarea
                throatareaType = throatarea
            }
            if (throatendpoint !== ""){
                throatItem.throatendcheck = true
                throatItem.throatendstate = throatendpoint
                throatendpointType = throatendpoint
            }
            if (throatlength !== ""){
                throatItem.throatlencheck = true
                throatItem.throatlenstate = throatlength
                throatlengthType = throatlength
            }
            if (throatperim !== ""){
                throatItem.throatpericheck = true
                throatItem.throatperistate = throatperim
                throatperimType = throatperim
            }
            if (throatshape !== ""){
                throatItem.throatshapecheck = true
                throatItem.throatshapestate = throatshape
                throatshapefactorType = throatshape
            }

            poreItem.porediamChange()
            poreItem.poreseedChange()
            poreItem.poresurfChange()
            poreItem.porevolChange()
            poreItem.poreareaChange()
            throatItem.throatdiamChange()
            throatItem.throatseedChange()
            throatItem.throatsurfChange()
            throatItem.throatvolChange()
            throatItem.throatareaChange()
            throatItem.throatendChange()
            throatItem.throatlenChange()
            throatItem.throatperiChange()
            throatItem.throatshapeChange()

            if (capillarypressure !== ""){
                physicItem.pccheck = true
                physicItem.pcstate = capillarypressure
                capillarypressureType = capillarypressure
            }

            if (diffusiveconductance !== ""){
                physicItem.diffcondcheck = true
                physicItem.diffcondstate = diffusiveconductance
                diffusivecondType = diffusiveconductance
            }
            if (hydraulicconductance !== ""){
                physicItem.hydcondcheck = true
                physicItem.hydcondstate = hydraulicconductance
                hydrauliccondType = hydraulicconductance
            }
            if (multiphase !== ""){
                physicItem.multicheck = true
                physicItem.multistate = multiphase
                multiphaseType = multiphase
            }
            if (flowshape !== ""){
                physicItem.flowshapecheck = true
                physicItem.flowshapestate = flowshape
                flowshapefactorType = flowshape
            }
            if (poissonshape !== ""){
                physicItem.poissonshapecheck = true
                physicItem.poissonshapestate = poissonshape
                poissonshapefactorType = poissonshape
            }
            physicItem.cpChange()
            physicItem.diffChange()
            physicItem.hydChange()
            physicItem.multiChange()
            physicItem.flowChange()
            physicItem.poiChange()

            if (den_inv !== ""){
                invadingItem.dencheck = true
                invadingItem.denstate = den_inv
                invadedensityType = den_inv
                invadingItem.denuser = invadedensityU
            }
            if (diff_inv !== ""){
                invadingItem.diffcheck = true
                invadingItem.diffstate = diff_inv
                invadediffusivityType = diff_inv
                invadingItem.changediff(invadeMWA, invadeMWB, invadeatomicvolA, invadeatomicvolB,
                                        invadediffcoeff, invademolvolA, invademolvolB,
                                        invadesurfA, invadesurfB)
                invadingItem.diffuser = invadediffusivityU
            }
            if (elec_inv !== ""){
                invadingItem.eleccheck = true
                invadingItem.changeelec(invadeperrelexp)
            }
            if (mix_inv !== ""){
                invadingItem.mixcheck = true
                invadingItem.mixstate = mix_inv
                invademixtureType = mix_inv
                invadingItem.changemixture(invadedickey)
                invadingItem.mixuser = invadesalinityU
            }
            if (molar_inv !== ""){
                invadingItem.molardencheck = true
                invadingItem.molardenstate = molar_inv
                invademolarType = molar_inv
                invadingItem.molaruser = invademolardenU
            }
            if (partcoeff_inv !== ""){
                invadingItem.partcoeffcheck = true
                invadingItem.changepartcoeff(invadechemicalformula)
            }
            if (permittivity_inv !== ""){
                invadingItem.pericheck = true
            }
            if (surf_inv !== ""){
                invadingItem.surfcheck = true
                invadingItem.surfstate = surf_inv
                invadesurfType = surf_inv
                invadingItem.changesurf(invadeconstparam, invadeK2, invadeN, invadesurfprop)
                invadingItem.surfuser = invadesurfU
            }
            if (vapor_inv !== ""){
                invadingItem.vaporcheck = true
                invadingItem.vaporstate = vapor_inv
                invadevaporType = vapor_inv
                invadingItem.changevapor(invadeprescoeffA, invadeprescoeffB, invadeprescoeffC)
                invadingItem.vaporuser = invadevaporU
            }
            if (vis_inv !== ""){
                invadingItem.vischeck = true
                invadingItem.visstate = vis_inv
                invadeviscosityType = vis_inv
                invadingItem.changevis(invadeviscoeffA, invadeviscoeffB)
                invadingItem.visuser = invadevisU
            }

            invadingItem.concen = concentration_inv
            invadingItem.press = pressure_inv
            invadingItem.temp = temp_inv
            invadingItem.volfrac = volfrac_inv
            invadingItem.intrinsic = intcond_inv
            invadingItem.mw = molweight_inv
            invadingItem.critemp = critemp_inv
            invadingItem.cripressure = cripressure_inv
            invadingItem.crivol = crivol_inv
            invadingItem.criangle = criangle_inv

            invadingItem.invadedenChange()
            invadingItem.invadediffChange()
            invadingItem.invademixChange()
            invadingItem.invademolarChange()
            invadingItem.invadesurfChange()
            invadingItem.invadevaporChange()
            invadingItem.invadevisChange()

            if (den_def !== ""){
                defendingItem.dencheck = true
                defendingItem.denstate = den_def
                defenddensityType = den_def
                defendingItem.denuser = defenddensityU
            }
            if (diff_def !== ""){
                defendingItem.diffcheck = true
                defendingItem.diffstate = diff_def
                defenddiffusivityType = diff_def
                defendingItem.changediff(defendMWA, defendMWB, defendatomicvolA, defendatomicvolB,
                                        defenddiffcoeff, defendmolvolA, defendmolvolB,
                                        defendsurfA, defendsurfB)
                defendingItem.diffuser = defenddiffusivityU
            }
            if (elec_def !== ""){
                defendingItem.eleccheck = true
                defendingItem.changeelec(defendperrelexp)
            }
            if (mix_def !== ""){
                defendingItem.mixcheck = true
                defendingItem.mixstate = mix_def
                defendmixtureType = mix_def
                defendingItem.changemixture(defenddickey)
                defendingItem.mixuser = defendsalinityU
            }
            if (molar_def !== ""){
                defendingItem.molardencheck = true
                defendingItem.molardenstate = molar_def
                defendmolarType = molar_def
                defendingItem.molaruser = defendmolardenU
            }
            if (partcoeff_def !== ""){
                defendingItem.partcoeffcheck = true
                defendingItem.changepartcoeff(defendchemicalformula)
            }
            if (permittivity_def !== ""){
                defendingItem.pericheck = true
            }
            if (surf_def !== ""){
                defendingItem.surfcheck = true
                defendingItem.surfstate = surf_def
                defendsurfType = surf_def
                defendingItem.changesurf(defendconstparam, defendK2, defendN, defendsurfprop)
                defendingItem.surfuser = defendsurfU
            }
            if (vapor_def !== ""){
                defendingItem.vaporcheck = true
                defendingItem.vaporstate = vapor_def
                defendvaporType = vapor_def
                defendingItem.changevapor(defendprescoeffA, defendprescoeffB, defendprescoeffC)
                defendingItem.vaporuser = defendvaporU
            }
            if (vis_def !== ""){
                defendingItem.vischeck = true
                defendingItem.visstate = vis_def
                defendviscosityType = vis_def
                defendingItem.changevis(defendviscoeffA, defendviscoeffB)
                defendingItem.visuser = defendvisU
            }

            defendingItem.concen = concentration_def
            defendingItem.press = pressure_def
            defendingItem.temp = temp_def
            defendingItem.volfrac = volfrac_def
            defendingItem.intrinsic = intcond_def
            defendingItem.mw = molweight_def
            defendingItem.critemp = critemp_def
            defendingItem.cripressure = cripressure_def
            defendingItem.crivol = crivol_def
            defendingItem.criangle = criangle_def

            defendingItem.defenddenChange()
            defendingItem.defenddiffChange()
            defendingItem.defendmixChange()
            defendingItem.defendmolarChange()
            defendingItem.defendsurfChange()
            defendingItem.defendvaporChange()
            defendingItem.defendvisChange()

            main1.phase_inv = phase_inv
            main1.phase_def = phase_def

            simulationItem.method = method
            simulationItem.simulationstate = method
            if (residual !== ""){
                simulationItem.rescheck = true
                simulationItem.resvalue = residual
            }

            if (trapping !== "false"){
                simulationItem.trapcheck = true
                simulationItem.trapping = true
            }

            poreprops.clear()
            for (var i=0; i<poreradius.length; i++){
                poreprops.append(
                            {
                                "Radi": poreradius[i]* 1000000/resolution,
                                "Coordx": porecoord[i][0]* 1000000/resolution,
                                "Coordy": porecoord[i][1]* 1000000/resolution,
                                "Coordz": porecoord[i][2]* 1000000/resolution
                            }
                            )
            }

            throatprops.clear()
            for (i=0; i<throatradius.length; i++){
                throatprops.append(
                            {
                                "Radi": throatradius[i]* 1000000/resolution,
                                "Length": throatlen[i]* 1000000/resolution,
                                "Centerx": throatcen[i][0]* 1000000/resolution,
                                "Centery": throatcen[i][1]* 1000000/resolution,
                                "Centerz": throatcen[i][2]* 1000000/resolution,
                                "Rotatex": rotation[i][0],
                                "Rotatey": rotation[i][1],
                                "Rotatez": rotation[i][2],
                                "Angle": angle[i]
                            }
                            )
            }

            psdxData = x_eval
            psdyData = y_eval
            psdnet.plot()
            tsdxData = x_eval2
            tsdyData = y_eval2
            tsdnet.plot()
            coordxData = coordinationx
            coordyData = coordinationy
            coordchart.plot()
            pcswxData = PCswx
            pcxData = PCpcx
            pcswyData = PCswy
            pcyData = PCpcy
            pcswzData = PCswz
            pczData = PCpcz
            pcchart.plot()

            krswxData = Krswx
            krswyData = Krswy
            krswzData = Krswz
            krwxData = Krwx
            krnwxData = Krnwx
            krwyData = Krwy
            krnwyData = Krnwy
            krwzData = Krwz
            krnwzData = Krnwz
            krchart.plot()

            drswxData = Drswx
            drswyData = Drswy
            drswzData = Drswz
            drwxData = Drwx
            drnwxData = Drnwx
            drwyData = Drwy
            drnwyData = Drnwy
            drwzData = Drwz
            drnwzData = Drnwz
            drchart.plot()

            resultmodel.clear()
            resultmodel.append({"text": "Total pores:  " + overal_pores})
            resultmodel.append({"text": "Connected pores: " + connected_pores})
            resultmodel.append({"text": "Isolated pores: " + isolated_pores})
            resultmodel.append({"text": "Total throats: " + overal_throats})
            resultmodel.append({"text": "Porosity: " + porosity  + " %"})
            resultmodel.append({"text": "Absolute permeability: " + K_tot  + " md"})
            resultmodel.append({"text": "Absolute diffusivity: " + String(D_tot)  + " mol/s"})

            sceneset.segmentVisible = false
            sceneset.reconstructVisible = false
            sceneset.throatVisible = true
            sceneset.poreVisible = true
            for (j=0; j<sceneModel.count; j++){
                if (sceneModel.get(j).name !== "3D Network"){
                    sceneModel.setProperty(j, "state", false)
                }else{
                    sceneModel.setProperty(j, "state", true)
                }
            }

            if (!findbyNameBool(sceneModel, "3D Network")){
                sceneModel.append(
                            {
                                "name":"3D Network",
                                "state": true
                            }
                            )
            }

            resultview.sResultview = 1
        }

        leftfilepanel.restart()
        successDynamicPop.messageText = "File opened successfully"
        animationdynamicpop.restart()
    }

    signal getTimer(var min, var sec)

    onGetTimer: {
        timer.text = min + ":" + sec
    }

    signal getPercent(var per)

    onGetPercent: {
        percent.text = per + "%"
    }

    signal changeStopButton()

    onChangeStopButton: {
        btn_state.btnstate = !btn_state.btnstate
    }

    property var msg
    property string saveScreenpath: ""

    function saveImage(){
        msg.saveImage(saveScreenpath)
        successDynamicPop.messageText = "Image saved successfully"
        animationdynamicpop.restart()
    }

    property real ratio : 1
    property double widthRatio: main1.width / 1920
    property double heightRatio: main1.height / 1080

    property alias rtxt: lbtext.text

    property string text3dcolor: "#ffffff"

    property bool inputvisible: inputmodel.count>0
    property bool imagehandlevisible: imagehandlemodel.count>0
    property bool reconstructvisible: reconstructmodel.count>0
    property bool networkvisible: networkmodel.count>0
    property bool geometryvisible: geometrymodel.count>0
    property bool physicvisible: physicmodel.count>0
    property bool phaseinvvisible: phaseinvmodel.count>0
    property bool phasedefvisible: phasedefmodel.count>0

    property string savePath: ""

    property string inputdata: ""
    property bool isGray: true

    property string inputType: ""

    property var porexData: []
    property var poreyData: []
    property var grainxData: []
    property var grainyData: []
    property var s2_x: []
    property var s2_y: []
    property var psdxData: []
    property var psdyData: []
    property var tsdxData: []
    property var tsdyData: []
    property var coordxData: []
    property var coordyData: []
    property var pcswxData: []
    property var pcxData: []
    property var pcswyData: []
    property var pcyData: []
    property var pcswzData: []
    property var pczData: []

    property var krswxData: []
    property var krswyData: []
    property var krswzData: []
    property var krwxData: []
    property var krnwxData: []
    property var krwyData: []
    property var krnwyData: []
    property var krwzData: []
    property var krnwzData: []

    property var drswxData: []
    property var drswyData: []
    property var drswzData: []
    property var drwxData: []
    property var drnwxData: []
    property var drwyData: []
    property var drnwyData: []
    property var drwzData: []
    property var drnwzData: []

    ListModel {id: poreprops}
    ListModel {id: throatprops}

    property real _Start: 2
    property real _DenoiseItem: _Start
    property real _FilterItem: _Start+1
    property real _SegmentationItem: _Start+2
    property real _StatisticalItem: _Start+3
    property real _MPSItem: _Start+4
    property real _CubicItem: _Start+5
    property real _CubicDualItem: _Start+6
    property real _BraivasItem: _Start+7
    property real _DelaunayVoronoiDualItem: _Start+8
    property real _VoronoiItem: _Start+9
    property real _DelaunayItem: _Start+10
    property real _GabrielItem: _Start+11
    property real _MaximalBallItem: _Start+12
    property real _SNOWItem: _Start+13
    property real _PoreItem: _Start+14
    property real _ThroatItem: _Start+15
    property real _PhysicItem: _Start+16
    property real _InvadingItem: _Start+17
    property real _DefendingItem: _Start+18
    property real _SimulationItem: _Start+19

    property bool porediam: false
    property string porediamType: ""
    property bool poreseed: false
    property string poreseedType: ""
    property bool poresurf: false
    property string poresurfType: ""
    property bool porevol: false
    property string porevolType: ""
    property bool porearea: false
    property string poreareaType: ""
    property bool throatdiam: false
    property string throatdiamType: ""
    property bool throatseed: false
    property string throatseedType: ""
    property bool throatsurf: false
    property string throatsurfType: ""
    property bool throatvol: false
    property string throatvolType: ""
    property bool throatarea: false
    property string throatareaType: ""
    property bool throatendpoint: false
    property string throatendpointType: ""
    property bool throatlength: false
    property string throatlengthType: ""
    property bool throatperim: false
    property string throatperimType: ""
    property bool throatshapefactor: false
    property string throatshapefactorType: ""
    property bool throatcentroid: true
    property bool throatvector: true
    property bool capillarypressure: true
    property string capillarypressureType: "Washburn"
    property bool diffusivecond: true
    property string diffusivecondType: "Mixed_diffusion"
    property bool hydrauliccond: true
    property string hydrauliccondType: "Hagen_poiseuille"
    property bool multiphase: false
    property string multiphaseType: "Conduit_conductance"
    property bool flowshapefactor: false
    property string flowshapefactorType: ""
    property bool poissonshapefactor: true
    property string poissonshapefactorType: "Ball_and_stick"
    property bool invadedensity: false
    property string invadedensityType: ""
    property bool defenddensity: false
    property string defenddensityType: ""
    property bool invadediffusivity: false
    property string invadediffusivityType: ""
    property bool defenddiffusivity: false
    property string defenddiffusivityType: ""
    property bool invadeelectrical: false
    property bool defendelectrical: false
    property bool invademixture: false
    property string invademixtureType: ""
    property bool defendmixture: false
    property string defendmixtureType: ""
    property bool invademolar: false
    property string invademolarType: ""
    property bool defendmolar: false
    property string defendmolarType: ""
    property bool invadepartcoeff: false
    property bool defendpartcoeff: false
    property bool invadepermittivity: false
    property bool defendpermittivity: false
    property bool invadesurf: false
    property string invadesurfType: ""
    property bool defendsurf: false
    property string defendsurfType: ""
    property bool invadevapor: false
    property string invadevaporType: ""
    property bool defendvapor: false
    property string defendvaporType: ""
    property bool invadeviscosity: false
    property string invadeviscosityType: ""
    property bool defendviscosity: false
    property string defendviscosityType: ""

    property string poreshape: ""
    property string porescale: ""
    property string poreloc: ""
    property string poremode: ""
    property string poreweightx: ""
    property string poreweighty: ""
    property string poreweightz: ""
    property string throatShape: ""
    property string throatscale: ""
    property string throatloc: ""
    property string throatmode: ""

    property string invadeMWA: ""
    property string invadeMWB: ""
    property string invadeatomicvolA: ""
    property string invadeatomicvolB: ""
    property string invadediffcoeff: ""
    property string invademolvolA: ""
    property string invademolvolB: ""
    property string invadesurfA: ""
    property string invadesurfB: ""
    property string invadeperrelexp: ""
    property string invadedickey: ""
    property string invadechemicalformula: ""
    property string invadeconstparam: ""
    property string invadeK2: ""
    property string invadeN: ""
    property string invadesurfprop: ""
    property string invadeprescoeffA: ""
    property string invadeprescoeffB: ""
    property string invadeprescoeffC: ""
    property string invadeviscoeffA: ""
    property string invadeviscoeffB: ""

    property string defendMWA: ""
    property string defendMWB: ""
    property string defendatomicvolA: ""
    property string defendatomicvolB: ""
    property string defenddiffcoeff: ""
    property string defendmolvolA: ""
    property string defendmolvolB: ""
    property string defendsurfA: ""
    property string defendsurfB: ""
    property string defendperrelexp: ""
    property string defenddickey: ""
    property string defendchemicalformula: ""
    property string defendconstparam: ""
    property string defendK2: ""
    property string defendN: ""
    property string defendsurfprop: ""
    property string defendprescoeffA: ""
    property string defendprescoeffB: ""
    property string defendprescoeffC: ""
    property string defendviscoeffA: ""
    property string defendviscoeffB: ""

    property string invadeconcentration: ""
    property string defendconcentration: ""
    property string invadepressure: ""
    property string defendpressure: ""
    property string invadetemp: ""
    property string defendtemp: ""
    property string invademoldiffvol: ""
    property string defendmoldiffvol: ""
    property string invadevolfrac: ""
    property string defendvolfrac: ""
    property string invadeintcond: ""
    property string defendintcond: ""
    property string invademolweight: ""
    property string defendmolweight: ""
    property string invadecritemp: ""
    property string defendcritemp: ""
    property string invadecripressure: ""
    property string defendcripressure: ""
    property string invadecrivol: ""
    property string defendcrivol: ""
    property string invadecriangle: ""
    property string defendcriangle: ""

    property string invadedensityU: ""
    property string invadediffusivityU: ""
    property string invadesalinityU: ""
    property string invademolardenU: ""
    property string invadesurfU: ""
    property string invadevaporU: ""
    property string invadevisU: ""
    property string defenddensityU: ""
    property string defenddiffusivityU: ""
    property string defendsalinityU: ""
    property string defendmolardenU: ""
    property string defendsurfU: ""
    property string defendvaporU: ""
    property string defendvisU: ""

    property bool psdImage: false
    property bool gsdImage: false
    property bool s2: false
    property bool psdnetwork: false
    property bool tsdnetwork: false
    property bool coord: false
    property bool cp: false
    property bool kr: false
    property bool dr: false

    property bool network: false
    property bool geometry: false

    property string phys_inv: ""
    property string phys_def: ""
    property string phase_inv: "Air"
    property string phase_def: "Water"

    property bool main_image: false
    property bool denoise_image: false
    property bool filter_image: false
    property bool segment_image: false
    property bool reconstruct_image: false

    ListModel{
        id: curvemodel

        ListElement{
            text: "3D image"
            number: 0
        }
    }
    ListModel{id: curvemodelstack}
    property real xdim: 0
    property real ydim: 0
    property real zdim: 1
    property string xdimReconstruct: ""
    property string ydimReconstruct: ""
    property string zdimReconstruct: ""
    property real resolution: 1
    property real totalPorosity: 0
    property alias swipTitle: lbtext.text

    FontLoader{ id: webfont; source: "./Fonts/materialdesignicons-webfont.ttf"}      //ICONS FONT
    //    FontLoader{ id: nunito; source: "qrc:/Content/Fonts/Nunito/Nunito-Regular.ttf"}      //ICONS FONT
    //    FontLoader{ id: nunito_italic; source: "qrc:/Content/Fonts/Nunito/Nunito-Italic.ttf"}      //ICONS FONT


    ListModel{id: tablemodel}
    ListModel{id: resultmodel}
    ListModel{id: inputmodel}
    ListModel{id: imagehandlemodel}
    ListModel{id: reconstructmodel}
    ListModel{id: networkmodel}
    ListModel{id: geometrymodel}
    ListModel{
        id: physicmodel
        ListElement{
            maintext: "Capillary pressure"
            proptext: "Capillary pressure (Weibull)"
        }
        ListElement{
            maintext: "Diffusive conductance"
            proptext: "Diffusive conductance (Mixed_diffusion)"
        }
        ListElement{
            maintext: "Hydraulic conductance"
            proptext: "Hydraulic conductance (Hagen_poiseuille)"
        }
        ListElement{
            maintext: "Multiphase"
            proptext: "Multiphase (Conduit_conductance)"
        }
        ListElement{
            maintext: "Poisson shape factor"
            proptext: "Poisson shape factor (Ball_and_stick)"
        }
    }
    ListModel{id: phaseinvmodel}
    ListModel{id: phasedefmodel}

    property bool expand: false
    onExpandChanged: {
        if(expand === false){
            leftfilepanel.restart()
        }
        else {
            rightfilepanel.restart()
        }
    }

    property bool expandvertical: false
    onExpandverticalChanged: {
        if(expandvertical === false){
            upsoftbar.restart()
        }
        else {
            downsoftbar.restart()
        }
    }

    //-- right Animation --//
    SequentialAnimation{
        id: rightfilepanel
        PropertyAnimation { target: filepanel ; properties: "visible"; to: true ; duration: 1 }
        PropertyAnimation { target: filepanel ; properties: "width"; to: 170*ratio ; duration: 300 }
    }

    //-- left Animation --//
    SequentialAnimation{
        id: leftfilepanel
        PropertyAnimation { target: filepanel ; properties: "width"; to: 0 ; duration: 300 }
        PropertyAnimation { target: filepanel ; properties: "visible"; to: false ; duration: 1 }
    }

    //-- down Animation --//
    ParallelAnimation{
        id: downsoftbar
        PropertyAnimation { target: softBars ; properties: "height"; to: 70 ; duration: 300 }
    }

    //-- Up Animation --//
    ParallelAnimation{
        id: upsoftbar
        PropertyAnimation { target: softBars ; properties: "height"; to: 0 ; duration: 300 }
    }

    property bool isHelpOn: false
    onIsHelpOnChanged : {
        if(isHelpOn === false){
            lefthelppanel.restart()
        }
        else {
            righthelppanel.restart()
        }
    }

    //-- right Animation --//
    ParallelAnimation{
        id: righthelppanel
        PropertyAnimation { target: helpview ; properties: "Layout.preferredWidth"; to: home.width * 0.2 ; duration: 300 }
    }

    //-- left Animation --//
    ParallelAnimation{
        id: lefthelppanel
        PropertyAnimation { target: helpview ; properties: "Layout.preferredWidth"; to: 0 ; duration: 300 }
    }

    property bool expandinput: false
    onExpandinputChanged: {
        if(expandinput === false){
            downinput.restart()
        }
        else {
            upinput.restart()
        }
    }
    //-- down Animation --//
    ParallelAnimation{
        id: downinput
        PropertyAnimation { target: logInputrec ; properties: "height"; to: logInputHandle.model.count*50 ; duration: 300 }
    }

    //-- Up Animation --//
    ParallelAnimation{
        id: upinput
        PropertyAnimation { target: logInputrec ; properties: "height"; to: 0 ; duration: 300 }
    }

    property bool expandimagehandle: false
    onExpandimagehandleChanged: {
        if(expandimagehandle === false){
            downimagehandle.restart()
        }
        else {
            upimagehandle.restart()
        }
    }
    //-- down Animation --//
    ParallelAnimation{
        id: downimagehandle
        PropertyAnimation { target: logImagerec ; properties: "height"; to: logImageHandle.model.count*50 ; duration: 300 }
    }

    //-- Up Animation --//
    ParallelAnimation{
        id: upimagehandle
        PropertyAnimation { target: logImagerec ; properties: "height"; to: 0 ; duration: 300 }
    }


    property bool expandreconstruct: false
    onExpandreconstructChanged: {
        if(expandreconstruct === false){
            downreconstruct.restart()
        }
        else {
            upreconstruct.restart()
        }
    }
    //-- down Animation --//
    ParallelAnimation{
        id: downreconstruct
        PropertyAnimation { target: logReconstructrec ; properties: "height"; to: logReconstructHandle.model.count*50 ; duration: 300 }
    }

    //-- Up Animation --//
    ParallelAnimation{
        id: upreconstruct
        PropertyAnimation { target: logReconstructrec ; properties: "height"; to: 0 ; duration: 300 }
    }


    property bool expandnetwork: false
    onExpandnetworkChanged: {
        if(expandnetwork === false){
            downnetwork.restart()
        }
        else {
            upnetwork.restart()
        }
    }
    //-- down Animation --//
    ParallelAnimation{
        id: downnetwork
        PropertyAnimation { target: logNetworkrec ; properties: "height"; to: logNetworkHandle.model.count*50 ; duration: 300 }
    }

    //-- Up Animation --//
    ParallelAnimation{
        id: upnetwork
        PropertyAnimation { target: logNetworkrec ; properties: "height"; to: 0 ; duration: 300 }
    }

    property bool expandgeometry: false
    onExpandgeometryChanged: {
        if(expandgeometry === false){
            downgeometry.restart()
        }
        else {
            upgeometry.restart()
        }
    }
    //-- down Animation --//
    ParallelAnimation{
        id: downgeometry
        PropertyAnimation { target: logGeometryrec ; properties: "height"; to: logGeometryHandle.model.count*25 ; duration: 300 }
    }

    //-- Up Animation --//
    ParallelAnimation{
        id: upgeometry
        PropertyAnimation { target: logGeometryrec ; properties: "height"; to: 0 ; duration: 300 }
    }

    property bool expandphysic: false
    onExpandphysicChanged: {
        if(expandphysic === false){
            downphysic.restart()
        }
        else {
            upphysic.restart()
        }
    }
    //-- down Animation --//
    ParallelAnimation{
        id: downphysic
        PropertyAnimation { target: logPhysicrec ; properties: "height"; to: logPhysicHandle.model.count*25 ; duration: 300 }
    }

    //-- Up Animation --//
    ParallelAnimation{
        id: upphysic
        PropertyAnimation { target: logPhysicrec ; properties: "height"; to: 0 ; duration: 300 }
    }


    property bool expandphaseinv: false
    onExpandphaseinvChanged: {
        if(expandphaseinv === false){
            downphaseinv.restart()
        }
        else {
            upphaseinv.restart()
        }
    }
    //-- down Animation --//
    ParallelAnimation{
        id: downphaseinv
        PropertyAnimation { target: logPhaseinvrec ; properties: "height"; to: logPhaseinvHandle.model.count*25 ; duration: 300 }
    }

    //-- Up Animation --//
    ParallelAnimation{
        id: upphaseinv
        PropertyAnimation { target: logPhaseinvrec ; properties: "height"; to: 0 ; duration: 300 }
    }

    property bool expandphasedef: false
    onExpandphasedefChanged: {
        if(expandphasedef === false){
            downphasedef.restart()
        }
        else {
            upphasedef.restart()
        }
    }
    //-- down Animation --//
    ParallelAnimation{
        id: downphasedef
        PropertyAnimation { target: logPhasedefrec ; properties: "height"; to: logPhasedefHandle.model.count*25 ; duration: 300 }
    }

    //-- Up Animation --//
    ParallelAnimation{
        id: upphasedef
        PropertyAnimation { target: logPhasedefrec ; properties: "height"; to: 0 ; duration: 300 }
    }

    //-- Header of main window --//
    Rectangle{
        id: header_rec
        width: parent.width
        height: softBars.height + header_tab.height
        color: "#a9a9a9"
        RowLayout{
            id: header_tab
            spacing: 0
            height: 35

            ButtonPanel2{
                id: btnfile

                Layout.fillWidth: true
                Layout.preferredHeight: 35 * ratio
                width: 80

                text: "File"
                color: "#1e90ff"

                onBtnClicked: {
                    expand = !expand

                }
            }

            ButtonPanel2{
                id: btninput

                Layout.fillWidth: true
                Layout.preferredHeight: 35 * ratio

                text: "Input"

                onBtnClicked: {
                    colorstate = !colorstate
                    btnreconstruct.colorstate = false
                    btnimagehandle.colorstate = false
                    btnsegment.colorstate = false
                    btnsimulation.colorstate = false
                    btnprops.colorstate = false
                    inputbar.visible = true
                    imagehandlingar.visible = false
                    reconstructionbar.visible = false
                    extractionbar.visible = false
                    simulationbar.visible = false
                    propertiesbar.visible = false
                    if (colorstate === !expandvertical) {expandvertical = !expandvertical}
                }
            }
            ButtonPanel2{
                id: btnimagehandle

                Layout.fillWidth: true
                Layout.preferredHeight: 35 * ratio
                text: "Image handling"

                onBtnClicked: {
                    colorstate = !colorstate
                    btnreconstruct.colorstate = false
                    btninput.colorstate = false
                    btnsegment.colorstate = false
                    btnsimulation.colorstate = false
                    btnprops.colorstate = false
                    inputbar.visible = false
                    imagehandlingar.visible = true
                    reconstructionbar.visible = false
                    extractionbar.visible = false
                    simulationbar.visible = false
                    propertiesbar.visible = false
                    if (colorstate === !expandvertical) {expandvertical = !expandvertical}
                }
            }
            ButtonPanel2{
                id: btnreconstruct

                Layout.fillWidth: true
                Layout.preferredHeight: 35 * ratio
                text: "Reconstruction"

                onBtnClicked: {
                    colorstate = !colorstate
                    btninput.colorstate = false
                    btnimagehandle.colorstate = false
                    btnsegment.colorstate = false
                    btnsimulation.colorstate = false
                    btnprops.colorstate = false
                    inputbar.visible = false
                    imagehandlingar.visible = false
                    reconstructionbar.visible = true
                    extractionbar.visible = false
                    simulationbar.visible = false
                    propertiesbar.visible = false
                    if (colorstate === !expandvertical) {expandvertical = !expandvertical}
                }
            }
            ButtonPanel2{
                id: btnsegment

                Layout.fillWidth: true
                Layout.preferredHeight: 35 * ratio
                text: "Network"

                onBtnClicked: {
                    colorstate = !colorstate
                    btnreconstruct.colorstate = false
                    btnimagehandle.colorstate = false
                    btninput.colorstate = false
                    btnsimulation.colorstate = false
                    btnprops.colorstate = false
                    inputbar.visible = false
                    imagehandlingar.visible = false
                    reconstructionbar.visible = false
                    extractionbar.visible = true
                    simulationbar.visible = false
                    propertiesbar.visible = false
                    if (colorstate === !expandvertical) {expandvertical = !expandvertical}

                }
            }
            ButtonPanel2{
                id: btnprops

                Layout.fillWidth: true
                Layout.preferredHeight: 35 * ratio
                text: "Properties"

                onBtnClicked: {
                    colorstate = !colorstate
                    btnreconstruct.colorstate = false
                    btnimagehandle.colorstate = false
                    btninput.colorstate = false
                    btnsegment.colorstate = false
                    btnsimulation.colorstate = false
                    inputbar.visible = false
                    imagehandlingar.visible = false
                    reconstructionbar.visible = false
                    extractionbar.visible = false
                    simulationbar.visible = false
                    propertiesbar.visible = true
                    if (colorstate === !expandvertical) {expandvertical = !expandvertical}

                }
            }

            ButtonPanel2{
                id: btnsimulation

                Layout.fillWidth: true
                Layout.preferredHeight: 35 * ratio
                text: "Simulation"

                onBtnClicked: {
                    colorstate = !colorstate
                    btnreconstruct.colorstate = false
                    btnimagehandle.colorstate = false
                    btninput.colorstate = false
                    btnsegment.colorstate = false
                    btnprops.colorstate = false
                    inputbar.visible = false
                    imagehandlingar.visible = false
                    reconstructionbar.visible = false
                    extractionbar.visible = false
                    simulationbar.visible = true
                    propertiesbar.visible = false
                    if (colorstate === !expandvertical) {expandvertical = !expandvertical}

                }
            }

        }

        Rectangle{
            id: softBars
            enabled: isLicensed //Enabled by license
            width: parent.width
            height: 0
            anchors.top: header_tab.bottom
            InputBar{
                id: inputbar
                anchors.fill: parent
                visible: false
            }
            ImageHandlingBar{
                id: imagehandlingar
                anchors.fill: parent
                visible: false
            }

            ReconstructionBar{
                id: reconstructionbar
                anchors.fill: parent
                visible: false
            }

            ExtractionBar{
                id: extractionbar
                anchors.fill: parent
                visible: false
            }

            PropertiesBar{
                id: propertiesbar
                anchors.fill: parent
                visible: false
            }

            SimulationBar{
                id: simulationbar
                anchors.fill: parent
                visible: false
            }
        }
    }

    //-- Home of main window --//
    RowLayout{
        id: home
        height: parent.height - header_rec.height
        width: parent.width
        anchors.left: parent.left
        anchors.top: header_rec.bottom
        spacing: 0
        clip: true

        //-- Left transition butoon --//
        Button{
            id: open_list
            Layout.fillHeight: true
            Layout.preferredWidth: 20
            palette {
                button: "#808080"
            }
            Label{
                anchors.fill: parent
                font.family: webfont.name
                font.pixelSize: Qt.application.font.pixelSize * 1.7
                text: logview.expandpanel ? Icons.arrow_right_box : Icons.arrow_left_box
                verticalAlignment: Qt.AlignVCenter
            }
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    logview.expandpanel = !logview.expandpanel
                }
            }
        }

        //-- Left Panel --//
        Rectangle{
            id: logview
            Layout.preferredWidth: parent.width * 0.2
            Layout.fillHeight: true
            color: "#f8f8ff"

            property bool expandpanel: false

            onExpandpanelChanged: {
                if(expandpanel === false){
                    rightpanel.restart()
                }
                else {
                    leftpanel.restart()
                }
            }

            //-- down Animation --//
            SequentialAnimation{
                id: rightpanel
                PropertyAnimation { target: logview ; properties: "visible"; to: true ; duration: 1 }
                PropertyAnimation { target: logview ; properties: "Layout.preferredWidth"; to: main1.width * 0.2 ; duration: 300 }
            }

            //-- Up Animation --//
            SequentialAnimation{
                id: leftpanel
                PropertyAnimation { target: logview ; properties: "Layout.preferredWidth"; to: 0 ; duration: 300 }
                PropertyAnimation { target: logview ; properties: "visible"; to: false ; duration: 1 }
            }

            Rectangle{
                anchors.fill: parent
                anchors.margins: 7

                layer.enabled: true
                layer.effect: DropShadow {
                    transparentBorder: true
                    horizontalOffset: 1//8
                    verticalOffset: 1//8
                    color: "#80000000"
                    spread: 0.0
                    samples: 17
                    radius: 12
                }
                ColumnLayout{
                    anchors.fill: parent
                    anchors.margins: 2

                    //-- list view header --//
                    ItemDelegate{
                        Layout.fillWidth: true

                        font.pixelSize: Qt.application.font.pixelSize

                        //- back color --//
                        Rectangle{anchors.fill: parent; color: "#a9a9a9"; radius:50; border{width: 1; color: "#22000000"}}

                        //-- materialCategory --//
                        Label{
                            id: lbtext
                            text: "Data"

                            font.pixelSize: Qt.application.font.pixelSize * 1.7
                            anchors.centerIn: parent
                        }
                        MouseArea{
                            anchors.fill: parent
                            onClicked: {
                                if (xdim === 0){
                                    swipTitle = "Data"
                                    section1.checked = true
                                    sView.currentIndex = 0
                                }else{
                                    swipTitle = "Input"
                                    section1.checked = true
                                    sView.currentIndex = 1
                                }

                            }
                        }
                    }

                    //-- SwipeView --//
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        MouseArea{
                            anchors.fill: parent
                            onClicked: {
                                if (expand === true){
                                    expand = !expand
                                }
                            }
                        }

                        SwipeView{
                            id: sView
                            anchors.fill: parent
                            interactive: false
                            visible: section1.checked
                            currentIndex: 0

                            Item{
                                objectName: "Start"
                                Rectangle{
                                    anchors.fill: parent
                                    color: "#20000000"

                                    Label{
                                        id: datatxt
                                        anchors.fill: parent
                                        text: "Data"
//                                        background: Image{
//                                            source: "Images/LeftPanel.png"
//                                            opacity: 0.1
//                                        }

                                        font.pixelSize: Qt.application.font.pixelSize * 5
                                        verticalAlignment: Text.AlignVCenter
                                        horizontalAlignment: Text.AlignHCenter
                                        color: "#1e90ff"
                                    }

                                    DropShadow {
                                        anchors.fill: datatxt
                                        horizontalOffset: 3
                                        verticalOffset: 15
                                        radius: 8.0
                                        samples: 17
                                        color: "#80000000"
                                        source: datatxt
                                    }
                                }
                            }

                            //-- Input Data Item --//
                            Item{
                                id: inputItem

                                InputItem{

                                }
                            }

                            //-- Denoise Item --//
                            Item{                               
                                DenoiseItem{
                                    id: denoiseItem

                                }
                            }

                            //-- Filter Item --//
                            Item{
                                FilterItem{
                                    id: filterItem

                                }
                            }


                            //-- Segmentation Item --//
                            Item{
                                SegmentationItem{
                                    id: segmentationItem

                                }
                            }

                            //-- Statistical Reconstruction Item --//
                            Item{
                                StatisticalItem{
                                    id: statisticalItem

                                }
                            }

                            //-- MPS Reconstruction Item --//
                            Item{
                                MPSItem{
                                    id: mpsItem

                                }
                            }

                            //-- Cubic Construction Item --//
                            Item{
                                CubicItem{
                                    id: cubicItem

                                }
                            }

                            //-- CubicDual Construction Item --//
                            Item{
                                CubicdualItem{
                                    id: cubicdualItem

                                }
                            }

                            //-- Braivas Construction Item --//
                            Item{
                                BravaisItem{
                                    id: braivasItem

                                }
                            }

                            //-- DelaunayVoronoiDual Construction Item --//
                            Item{
                                DelaunayVoronoiDualItem{
                                    id: delaunayvoronoidualItem

                                }
                            }

                            //-- Voronoi Construction Item --//
                            Item{
                                VoronoiItem{
                                    id: voronoiItem

                                }
                            }

                            //-- Delaunay Construction Item --//
                            Item{
                                DelaunayItem{
                                    id: delaunayItem

                                }
                            }

                            //-- Gabriel Construction Item --//
                            Item{
                                GabrielItem{
                                    id: gabrielItem

                                }
                            }

                            //-- Maximal Ball Extraction Item --//
                            Item{
                                MaximalBallItem{
                                    id: maximalballItem

                                }
                            }

                            //-- SNOW Extraction Item --//
                            Item{
                                SNOWItem{
                                    id: snowItem
                                }
                            }

                            //-- Pore Item --//
                            Item{

                                PoreItem{
                                    id: poreItem
                                }
                            }

                            //-- Throat Item --//
                            Item{

                                ThroatItem{
                                    id: throatItem

                                }
                            }

                            //-- Physic Item --//
                            Item{

                                PhysicItem{
                                    id: physicItem
                                }
                            }

                            //-- Invading Item --//
                            Item{

                                InvadingItem{
                                    id: invadingItem

                                }
                            }

                            //-- defending Item --//
                            Item{

                                DefendingItem{
                                    id: defendingItem

                                }
                            }

                            //-- simuation Item --//
                            Item{

                                SimulationItem{
                                    id: simulationItem

                                }
                            }
                        }

                        Rectangle{
                            id: logView
                            anchors.fill: parent
                            visible: section2.checked
                            objectName: "Start"

                            color: "#20000000"

                            Label{
                                id: headeritem
                                anchors.top: parent.top
                                anchors.left: parent.left
                                width: parent.width
                                height: 40
                                z: 1
                                background: Rectangle {
                                    color: "#f8f8ff"
                                }


                                font.pixelSize: Qt.application.font.pixelSize
                                font.bold: true
                                verticalAlignment: Text.AlignVCenter
                                text: "Simulation Chart"
                            }


                            Flickable{
                                id: imagehandleflick
                                anchors.top: headeritem.bottom
                                height: parent.height - headeritem.height
                                width: parent.width
                                clip: true

                                contentWidth: parent.width
                                contentHeight:
                                    (logInputHandle.height + 25) + (logReconstructHandle.height + 25) + (logImageHandle.height + 25)
                                    + (logNetworkHandle.height + 25) + (logGeometryHandle.height + 25)
                                    + (logPhysicHandle.height + 25) + (logPhaseinvHandle.height + 25)
                                    + (logPhasedefHandle.height + 25)

                                ScrollBar.vertical: ScrollBar {

                                }
                                Column{
                                    id: logcolumn
                                    anchors.fill: parent

                                    // -- Iuput log -- //
                                    Rectangle{
                                        width: parent.width
                                        height: 25
                                        visible: inputvisible
                                        color: "#696969"
                                        border.color: "#888"
                                        radius: 4
                                        gradient: Gradient {
                                            GradientStop { position: 0 ; color: "#696969"}
                                            GradientStop { position: 1 ; color: "#aaa"}
                                        }
                                        RowLayout{
                                            anchors.fill: parent
                                            spacing: 0
                                            Label{
                                                Layout.fillHeight: true
                                                Layout.preferredWidth: parent.width*0.9
                                                verticalAlignment: Text.AlignVCenter
                                                horizontalAlignment: Text.AlignHCenter

                                                font.bold: true
                                                text: "Input"
                                                color: "white"
                                            }

                                            Label{
                                                Layout.fillHeight: true
                                                verticalAlignment: Text.AlignVCenter
                                                horizontalAlignment: Text.AlignHCenter
                                                Layout.preferredWidth: parent.width*0.1

                                                font.family: webfont.name
                                                font.pixelSize: 20
                                                text: expandinput ? Icons.chevron_down: Icons.chevron_up
                                            }
                                        }
                                        MouseArea{
                                            anchors.fill: parent
                                            onClicked: {
                                                expandinput = !expandinput
                                            }
                                        }
                                    }

                                    Rectangle{
                                        id: logInputrec
                                        width: parent.width
                                        height: logInputHandle.model.count * 50
                                        visible: inputvisible
                                        ListView{
                                            id: logInputHandle
                                            anchors.fill: parent
                                            spacing: 0
                                            clip: true
                                            model: inputmodel
                                            delegate: Rectangle{
                                                width: parent.width
                                                height: 50
                                                objectName: index
                                                color: (index%2 == 0 ) ? "#ffffff":"#c0c0c0"
                                                ColumnLayout{
                                                    anchors.fill: parent
                                                    spacing: 0
                                                    Label{
                                                        Layout.fillWidth: true
                                                        Layout.preferredHeight: parent.height/2
                                                        verticalAlignment: Text.AlignVCenter
                                                        text: model.maintext
                                                    }
                                                    Label{
                                                        Layout.fillWidth: true
                                                        Layout.preferredHeight: parent.height/2
                                                        verticalAlignment: Text.AlignVCenter
                                                        text: model.proptext
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    // **** spacer ****//
                                    Rectangle{
                                        width: parent.width
                                        height: 3
                                        color: "transparent"
                                    }


                                    // -- Image handling log -- //
                                    Rectangle{
                                        width: parent.width
                                        height: 25
                                        visible: imagehandlevisible
                                        color: "#696969"
                                        border.color: "#888"
                                        radius: 4
                                        gradient: Gradient {
                                            GradientStop { position: 0 ; color: "#696969"}
                                            GradientStop { position: 1 ; color: "#aaa"}
                                        }
                                        RowLayout{
                                            anchors.fill: parent
                                            spacing: 0
                                            Label{
                                                Layout.fillHeight: true
                                                Layout.preferredWidth: parent.width*0.9
                                                verticalAlignment: Text.AlignVCenter
                                                horizontalAlignment: Text.AlignHCenter

                                                font.bold: true
                                                text: "Image Handling"
                                                color: "white"
                                            }

                                            Label{
                                                Layout.fillHeight: true
                                                verticalAlignment: Text.AlignVCenter
                                                horizontalAlignment: Text.AlignHCenter
                                                Layout.preferredWidth: parent.width*0.1

                                                font.family: webfont.name
                                                font.pixelSize: 20
                                                text: expandimagehandle ? Icons.chevron_down: Icons.chevron_up
                                            }
                                        }
                                        MouseArea{
                                            anchors.fill: parent
                                            onClicked: {
                                                expandimagehandle =! expandimagehandle
                                            }
                                        }
                                    }

                                    Rectangle{
                                        id: logImagerec
                                        width: parent.width
                                        height: logImageHandle.model.count * 50
                                        visible: imagehandlevisible
                                        ListView{
                                            id: logImageHandle
                                            anchors.fill: parent
                                            spacing: 0
                                            clip: true
                                            model: imagehandlemodel
                                            delegate: Rectangle{
                                                width: parent.width
                                                height: 50
                                                objectName: index
                                                color: (index%2 == 0 ) ? "#ffffff":"#c0c0c0"
                                                ColumnLayout{
                                                    anchors.fill: parent
                                                    spacing: 0
                                                    Label{
                                                        Layout.fillWidth: true
                                                        Layout.preferredHeight: parent.height/2
                                                        verticalAlignment: Text.AlignVCenter
                                                        text: model.maintext
                                                    }
                                                    Label{
                                                        Layout.fillWidth: true
                                                        Layout.preferredHeight: parent.height/2
                                                        font.pixelSize: Qt.application.font.pixelSize
                                                        verticalAlignment: Text.AlignVCenter
                                                        text: model.proptext
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    // **** spacer ****//
                                    Rectangle{
                                        width: parent.width
                                        height: 3
                                        color: "transparent"
                                    }

                                    // -- Reconstruction log -- //
                                    Rectangle{
                                        width: parent.width
                                        height: 25
                                        visible: reconstructvisible
                                        color: "#696969"
                                        border.color: "#888"
                                        radius: 4
                                        gradient: Gradient {
                                            GradientStop { position: 0 ; color: "#696969"}
                                            GradientStop { position: 1 ; color: "#aaa"}
                                        }
                                        RowLayout{
                                            anchors.fill: parent
                                            spacing: 0
                                            Label{
                                                Layout.fillHeight: true
                                                Layout.preferredWidth: parent.width*0.9
                                                verticalAlignment: Text.AlignVCenter
                                                horizontalAlignment: Text.AlignHCenter

                                                font.bold: true
                                                text: "Image Reconstruction"
                                                color: "white"
                                            }

                                            Label{
                                                Layout.fillHeight: true
                                                verticalAlignment: Text.AlignVCenter
                                                horizontalAlignment: Text.AlignHCenter
                                                Layout.preferredWidth: parent.width*0.1
                                                font.family: webfont.name
                                                font.pixelSize: 20
                                                text: expandreconstruct ? Icons.chevron_down: Icons.chevron_up
                                            }
                                        }
                                        MouseArea{
                                            anchors.fill: parent
                                            onClicked: {
                                                expandreconstruct =! expandreconstruct
                                            }
                                        }
                                    }

                                    Rectangle{
                                        id: logReconstructrec
                                        width: parent.width
                                        height: logReconstructHandle.model.count * 50
                                        visible: reconstructvisible
                                        ListView{
                                            id: logReconstructHandle
                                            anchors.fill: parent
                                            spacing: 0
                                            clip: true
                                            model: reconstructmodel
                                            delegate: Rectangle{
                                                width: parent.width
                                                height: 50
                                                objectName: index
                                                color: (index%2 == 0 ) ? "#ffffff":"#c0c0c0"
                                                ColumnLayout{
                                                    anchors.fill: parent
                                                    spacing: 0
                                                    Label{
                                                        Layout.fillWidth: true
                                                        Layout.preferredHeight: parent.height/2
                                                        verticalAlignment: Text.AlignVCenter
                                                        text: model.maintext
                                                    }
                                                    Label{
                                                        Layout.fillWidth: true
                                                        Layout.preferredHeight: parent.height/2
                                                        verticalAlignment: Text.AlignVCenter
                                                        text: model.proptext
                                                    }
                                                }
                                            }
                                        }

                                    }

                                    // **** spacer ****//
                                    Rectangle{
                                        width: parent.width
                                        height: 3
                                        color: "transparent"
                                    }

                                    // -- Network log -- //
                                    Rectangle{
                                        width: parent.width
                                        height: 25
                                        visible: networkvisible
                                        color: "#696969"
                                        border.color: "#888"
                                        radius: 4
                                        gradient: Gradient {
                                            GradientStop { position: 0 ; color: "#696969"}
                                            GradientStop { position: 1 ; color: "#aaa"}
                                        }
                                        RowLayout{
                                            anchors.fill: parent
                                            spacing: 0
                                            Label{
                                                Layout.fillHeight: true
                                                Layout.preferredWidth: parent.width*0.9
                                                verticalAlignment: Text.AlignVCenter
                                                horizontalAlignment: Text.AlignHCenter

                                                font.bold: true
                                                text: "Network"
                                                color: "white"
                                            }

                                            Label{
                                                Layout.fillHeight: true
                                                verticalAlignment: Text.AlignVCenter
                                                horizontalAlignment: Text.AlignHCenter
                                                Layout.preferredWidth: parent.width*0.1
                                                font.family: webfont.name
                                                font.pixelSize: 20
                                                text: expandnetwork ? Icons.chevron_down: Icons.chevron_up
                                            }
                                        }
                                        MouseArea{
                                            anchors.fill: parent
                                            onClicked: {
                                                expandnetwork =! expandnetwork
                                            }
                                        }
                                    }

                                    Rectangle{
                                        id: logNetworkrec
                                        width: parent.width
                                        height: logNetworkHandle.model.count * 50
                                        visible: networkvisible
                                        ListView{
                                            id: logNetworkHandle
                                            anchors.fill: parent
                                            spacing: 0
                                            clip: true
                                            model: networkmodel
                                            delegate: Rectangle{
                                                width: parent.width
                                                height: 50
                                                objectName: index
                                                color: (index%2 == 0 ) ? "#ffffff":"#c0c0c0"
                                                ColumnLayout{
                                                    anchors.fill: parent
                                                    spacing: 0
                                                    Label{
                                                        Layout.fillWidth: true
                                                        Layout.preferredHeight: parent.height/2
                                                        verticalAlignment: Text.AlignVCenter
                                                        text: model.maintext
                                                    }
                                                    Label{
                                                        Layout.fillWidth: true
                                                        Layout.preferredHeight: parent.height/2
                                                        verticalAlignment: Text.AlignVCenter
                                                        text: model.proptext
                                                    }
                                                }
                                            }
                                        }

                                    }

                                    // **** spacer ****//
                                    Rectangle{
                                        width: parent.width
                                        height: 3
                                        color: "transparent"
                                    }

                                    // -- Geometry log -- //
                                    Rectangle{
                                        width: parent.width
                                        height: 25
                                        visible: geometryvisible
                                        color: "#696969"
                                        border.color: "#888"
                                        radius: 4
                                        gradient: Gradient {
                                            GradientStop { position: 0 ; color: "#696969"}
                                            GradientStop { position: 1 ; color: "#aaa"}
                                        }
                                        RowLayout{
                                            anchors.fill: parent
                                            spacing: 0
                                            Label{
                                                Layout.fillHeight: true
                                                Layout.preferredWidth: parent.width*0.9
                                                verticalAlignment: Text.AlignVCenter
                                                horizontalAlignment: Text.AlignHCenter

                                                font.bold: true
                                                text: "Geometry"
                                                color: "white"
                                            }

                                            Label{
                                                Layout.fillHeight: true
                                                verticalAlignment: Text.AlignVCenter
                                                horizontalAlignment: Text.AlignHCenter
                                                Layout.preferredWidth: parent.width*0.1
                                                font.family: webfont.name
                                                font.pixelSize: 20
                                                text: expandgeometry ? Icons.chevron_down: Icons.chevron_up
                                            }
                                        }
                                        MouseArea{
                                            anchors.fill: parent
                                            onClicked: {
                                                expandgeometry =! expandgeometry
                                            }
                                        }
                                    }

                                    Rectangle{
                                        id: logGeometryrec
                                        width: parent.width
                                        height: logGeometryHandle.model.count * 25
                                        visible: geometryvisible
                                        ListView{
                                            id: logGeometryHandle
                                            anchors.fill: parent
                                            spacing: 0
                                            clip: true
                                            model: geometrymodel
                                            delegate: Rectangle{
                                                width: parent.width
                                                height: 25
                                                objectName: index
                                                color: (index%2 == 0 ) ? "#ffffff":"#c0c0c0"
                                                Label{
                                                    anchors.fill: parent
                                                    text: model.proptext
                                                }

                                            }
                                        }

                                    }

                                    // **** spacer ****//
                                    Rectangle{
                                        width: parent.width
                                        height: 3
                                        color: "transparent"
                                    }

                                    // -- Physic log -- //
                                    Rectangle{
                                        width: parent.width
                                        height: 25
                                        visible: true
                                        color: "#696969"
                                        border.color: "#888"
                                        radius: 4
                                        gradient: Gradient {
                                            GradientStop { position: 0 ; color: "#696969"}
                                            GradientStop { position: 1 ; color: "#aaa"}
                                        }
                                        RowLayout{
                                            anchors.fill: parent
                                            spacing: 0
                                            Label{
                                                Layout.fillHeight: true
                                                Layout.preferredWidth: parent.width*0.9
                                                verticalAlignment: Text.AlignVCenter
                                                horizontalAlignment: Text.AlignHCenter

                                                font.bold: true
                                                text: "Physics"
                                                color: "white"
                                            }

                                            Label{
                                                Layout.fillHeight: true
                                                verticalAlignment: Text.AlignVCenter
                                                horizontalAlignment: Text.AlignHCenter
                                                Layout.preferredWidth: parent.width*0.1
                                                font.family: webfont.name
                                                font.pixelSize: 20
                                                text: expandphysic ? Icons.chevron_down: Icons.chevron_up
                                            }
                                        }
                                        MouseArea{
                                            anchors.fill: parent
                                            onClicked: {
                                                expandphysic =! expandphysic
                                            }
                                        }
                                    }

                                    Rectangle{
                                        id: logPhysicrec
                                        width: parent.width
                                        height: logPhysicHandle.model.count * 25
                                        visible: physicvisible
                                        ListView{
                                            id: logPhysicHandle
                                            anchors.fill: parent
                                            spacing: 0
                                            clip: true
                                            model: physicmodel
                                            delegate: Rectangle{
                                                width: parent.width
                                                height: 25
                                                objectName: index
                                                color: (index%2 == 0 ) ? "#ffffff":"#c0c0c0"
                                                Label{
                                                    anchors.fill: parent
                                                    verticalAlignment: Text.AlignVCenter
                                                    text: model.proptext
                                                }

                                            }
                                        }

                                    }

                                    // **** spacer ****//
                                    Rectangle{
                                        width: parent.width
                                        height: 3
                                        color: "transparent"
                                    }
                                    // -- Phase inv log -- //
                                    Rectangle{
                                        width: parent.width
                                        height: 25
                                        visible: true
                                        color: "#696969"
                                        border.color: "#888"
                                        radius: 4
                                        gradient: Gradient {
                                            GradientStop { position: 0 ; color: "#696969"}
                                            GradientStop { position: 1 ; color: "#aaa"}
                                        }
                                        RowLayout{
                                            anchors.fill: parent
                                            spacing: 0
                                            Label{
                                                Layout.fillHeight: true
                                                Layout.preferredWidth: parent.width*0.9
                                                verticalAlignment: Text.AlignVCenter
                                                horizontalAlignment: Text.AlignHCenter

                                                font.bold: true
                                                text: phase_inv + " (Invader)"
                                                color: "white"
                                            }

                                            Label{
                                                Layout.fillHeight: true
                                                verticalAlignment: Text.AlignVCenter
                                                horizontalAlignment: Text.AlignHCenter
                                                Layout.preferredWidth: parent.width*0.1
                                                font.family: webfont.name
                                                font.pixelSize: 20
                                                text: expandphaseinv ? Icons.chevron_down: Icons.chevron_up
                                            }
                                        }
                                        MouseArea{
                                            anchors.fill: parent
                                            onClicked: {
                                                expandphaseinv =! expandphaseinv
                                            }
                                        }
                                    }

                                    Rectangle{
                                        id: logPhaseinvrec
                                        width: parent.width
                                        height: logPhaseinvHandle.model.count * 25
                                        visible: phaseinvvisible
                                        ListView{
                                            id: logPhaseinvHandle
                                            anchors.fill: parent
                                            spacing: 0
                                            clip: true
                                            model: phaseinvmodel
                                            delegate: Rectangle{
                                                width: parent.width
                                                height: 25
                                                objectName: index
                                                color: (index%2 == 0 ) ? "#ffffff":"#c0c0c0"
                                                Label{
                                                    anchors.fill: parent
                                                    verticalAlignment: Text.AlignVCenter
                                                    text: model.proptext
                                                }

                                            }
                                        }

                                    }

                                    // **** spacer ****//
                                    Rectangle{
                                        width: parent.width
                                        height: 3
                                        color: "transparent"
                                    }
                                    // -- Phase def log -- //
                                    Rectangle{
                                        width: parent.width
                                        height: 25
                                        visible: true
                                        color: "#696969"
                                        border.color: "#888"
                                        radius: 4
                                        gradient: Gradient {
                                            GradientStop { position: 0 ; color: "#696969"}
                                            GradientStop { position: 1 ; color: "#aaa"}
                                        }
                                        RowLayout{
                                            anchors.fill: parent
                                            spacing: 0
                                            Label{
                                                Layout.fillHeight: true
                                                Layout.preferredWidth: parent.width*0.9
                                                verticalAlignment: Text.AlignVCenter
                                                horizontalAlignment: Text.AlignHCenter

                                                font.bold: true
                                                text: phase_def + " (Defender)"
                                                color: "white"
                                            }

                                            Label{
                                                Layout.fillHeight: true
                                                verticalAlignment: Text.AlignVCenter
                                                horizontalAlignment: Text.AlignHCenter
                                                Layout.preferredWidth: parent.width*0.1
                                                font.family: webfont.name
                                                font.pixelSize: 20
                                                text: expandphasedef ? Icons.chevron_down: Icons.chevron_up
                                            }
                                        }
                                        MouseArea{
                                            anchors.fill: parent
                                            onClicked: {
                                                expandphasedef =! expandphasedef
                                            }
                                        }
                                    }

                                    Rectangle{
                                        id: logPhasedefrec
                                        width: parent.width
                                        height: logPhasedefHandle.model.count * 25
                                        visible: phasedefvisible
                                        ListView{
                                            id: logPhasedefHandle
                                            anchors.fill: parent
                                            spacing: 0
                                            clip: true
                                            model: phasedefmodel
                                            delegate: Rectangle{
                                                width: parent.width
                                                height: 25
                                                objectName: index
                                                color: (index%2 == 0 ) ? "#ffffff":"#c0c0c0"
                                                Label{
                                                    anchors.fill: parent
                                                    verticalAlignment: Text.AlignVCenter
                                                    text: model.proptext
                                                }

                                            }
                                        }

                                    }

                                    // **** spacer ****//
                                    Rectangle{
                                        width: parent.width
                                        height: 3
                                        color: "transparent"
                                    }


                                }
                            }
                        }
                    }


                    //-- footer of left layout--//
                    TabBar {
                        id: bar
                        Layout.fillWidth: true
                        rotation: 180

                        font.pixelSize: Qt.application.font.pixelSize
                        Material.accent: "#6c88b7"

                        currentIndex: 1

                        //-- Section 2 Button --//
                        TabButton {
                            id: section2
                            rotation: 180

                            signal checkSection2()
                            onCheckSection2: {
                                checked = true
                                rtxt = "Log"
                            }

                            Label{
                                text: "Log"
                                font.bold: section2.checked ? true : false
                                font.pixelSize: section2.checked ? Qt.application.font.pixelSize * 1.1 : Qt.application.font.pixelSize
                                color: section2.checked ? "#000000" : "#aaaaaa"
                                anchors.centerIn: parent
                            }

                            onClicked: {
                                checkSection2()
                            }
                        }

                        //-- Section 1 Button --//
                        TabButton {
                            id: section1
                            rotation: 180

                            signal checkSection1()
                            onCheckSection1: {
                                checked = true
                                rtxt = "Data"
                            }

                            Label{
                                text: "Data"
                                font.bold: section1.checked ? true : false
                                font.pixelSize: section1.checked ? Qt.application.font.pixelSize * 1.1 : Qt.application.font.pixelSize
                                color: section1.checked ? "#000000" : "#aaaaaa"
                                anchors.centerIn: parent
                            }

                            onClicked: {
                                checkSection1()
                            }

                        }

                    }

                }
            }
        }

        //-- Help Panel --//
        Rectangle{
            id: helpview
            Layout.preferredWidth: 0
            Layout.fillHeight: true
            color: "#f8f8ff"
            Rectangle{
                anchors.fill: parent
                anchors.margins: 7

                layer.enabled: true
                layer.effect: DropShadow {
                    transparentBorder: true
                    horizontalOffset: 1//8
                    verticalOffset: 1//8
                    color: "#80000000"
                    spread: 0.0
                    samples: 17
                    radius: 12
                }
                ColumnLayout{
                    anchors.fill: parent
                    anchors.margins: 2

                    Row{
                        Layout.fillWidth: true
                        Layout.preferredHeight: parent.height * 0.1
                        spacing: 0
                        //-- list view header --//
                        ItemDelegate{
                            width: parent.width * 0.8

                            font.pixelSize: Qt.application.font.pixelSize

                            //- back color --//
                            Rectangle{anchors.fill: parent; color: "#a9a9a9"; radius:50; border{width: 1; color: "#22000000"}}

                            //-- materialCategory --//
                            Label{
                                text: "Help"

                                font.pixelSize: Qt.application.font.pixelSize * 1.7
                                anchors.centerIn: parent
                            }

                        }

                        ItemDelegate{
                            width: parent.width * 0.2

                            font.pixelSize: Qt.application.font.pixelSize

                            //-- materialCategory --//
                            Label{
                                font.family: webfont.name
                                font.pixelSize: Qt.application.font.pixelSize * 3.5
                                text: Icons.close_circle_outline
                                verticalAlignment: Qt.AlignVCenter
                                anchors.centerIn: parent

                                MouseArea{
                                    anchors.fill: parent
                                    onClicked: {
                                        isHelpOn = !isHelpOn
                                    }
                                }
                            }

                        }
                    }

                    //-- Help ListView --//
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true

                        ColumnLayout{
                            anchors.fill: parent

                            Label{
                                id: lbl_lv
                                Layout.fillWidth: true
                                Layout.preferredHeight: lbl_lv.implicitHeight
                                text: "Based of the choosen properties you should add the following properties too"
                                font.bold: true
                                renderType: Text.NativeRendering
                                wrapMode: Text.WordWrap
                                z: 1
                            }

                            ListView{
                                id: helplist
                                Layout.fillWidth: true
                                Layout.preferredHeight: parent.height - lbl_lv.height
                                clip: true
                                model: ListModel{
                                    id: helpmodel
                                }

                                delegate: Rectangle {
                                    id: helpitem
                                    width: helplist.width
                                    height: 50

                                    color: "#f8f8ff"

                                    RowLayout{
                                        anchors.fill: parent
                                        spacing: 0
                                        Label{
                                            Layout.fillHeight: true
                                            Layout.preferredWidth: parent.width * 0.1

                                            font.family: webfont.name
                                            font.pixelSize: Qt.application.font.pixelSize * 1.5
                                            text: (model.check) ? Icons.check:Icons.close_outline
                                            verticalAlignment: Qt.AlignVCenter
                                        }
                                        Label{
                                            Layout.fillHeight: true
                                            Layout.preferredWidth: parent.width * 0.9
                                            verticalAlignment: Qt.AlignVCenter
                                            font.pixelSize: Qt.application.font.pixelSize * 1.5

                                            text: model.text
                                        }
                                    }

                                }
                            }
                        }
                    }
                }
            }
        }

        //-- Middle Panel --//
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            TabBar{
                id: bar_main
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                contentHeight: 30
                contentWidth: curvemodel.count * 200
                clip: true
                background: Rectangle{
                    border.color: "#dcdcdc"
                    radius: 15
                    border.width: 3
                }

                Repeater {
                    model: curvemodel

                    TabButton {
                        id: tabbtn
                        text: model.text
                        width: 200
                        background: Rectangle {

                            border.width: 3
                            border.color: "#dcdcdc"
                            color: "transparent"
                            radius: 15
                        }
                    }
                }
            }

            Rectangle{
                Layout.fillWidth: true
                Layout.preferredHeight: home.height - 70
                clip: true
                Scene3D {
                    id: scene3d
                    anchors.fill: parent
                    focus: true
                    aspects: ["input", "logic"]
                    cameraAspectRatioMode: Scene3D.AutomaticAspectRatio
                }
                StackLayout {
                    id: barMainStack
                    anchors.fill: parent
                    currentIndex: curvemodel.get(bar_main.currentIndex).number

                    Rectangle {
                        id: view3d
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: Qt.rgba(25/255, 51/255, 77/255, 1)

                        Scene3DView{
                            id: view1
                            scene3D: scene3d
                            anchors.fill: parent
                            anchors.margins: 10

                            ThreeDimensionalScene{
                                id: sceneset
                                backgroundColor: view3d.color
                                x: xdim
                                y: ydim
                                z: zdim
                                x2: xdimReconstruct
                                y2: ydimReconstruct
                                z2: zdimReconstruct
                                x3: (findbyNameBool(sceneModel, "3D Reconstruct")) ? xdimReconstruct:xdim
                                y3: (findbyNameBool(sceneModel, "3D Reconstruct")) ? ydimReconstruct:ydim
                                z3: (findbyNameBool(sceneModel, "3D Reconstruct")) ? zdimReconstruct:zdim
                                poreModel: poreprops
                                x4: (findbyNameBool(sceneModel, "3D Reconstruct")) ? xdimReconstruct:xdim
                                y4: (findbyNameBool(sceneModel, "3D Reconstruct")) ? ydimReconstruct:ydim
                                z4: (findbyNameBool(sceneModel, "3D Reconstruct")) ? zdimReconstruct:zdim
                                throatModel: throatprops
                            }

                        }

                        ListModel {
                            id: sceneModel
                        }
                        ListModel {
                            id: scene2dModel
                        }

                        Column {
                            spacing: 20
                            topPadding: 20
                            leftPadding: 10
                            ListView{
                                //                            anchors.verticalCenter: parent.verticalCenter
                                height: sceneModel.count * 40
                                spacing: 5
                                width: 40
                                interactive: false
                                model: sceneModel
                                delegate: Rectangle {
                                    id: sceneRect
                                    width: 120
                                    height: 40
                                    radius: 20
                                    color: (model.state) ? text3dcolor.replace("#", "#50"):"transparent"
                                    Text {
                                        id: sceneText
                                        anchors.centerIn: parent
                                        font.family: "Helvetica"
                                        font.pixelSize: 16
                                        font.weight: Font.Light
                                        color: text3dcolor
                                        opacity: 1
                                        text: model.name
                                    }
                                    MouseArea{
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onEntered: {
                                            cursorShape = Qt.PointingHandCursor
                                        }
                                        onExited: {
                                            cursorShape = Qt.ArrowCursor
                                        }
                                        onClicked: {
                                            if (model.name === "3D Segment"){
                                                sceneset.segmentVisible = !sceneset.segmentVisible
                                            }else if (model.name === "3D Reconstruct"){
                                                sceneset.reconstructVisible = !sceneset.reconstructVisible
                                            }else if (model.name === "3D Network"){
                                                sceneset.poreVisible = !sceneset.poreVisible
                                                sceneset.throatVisible = !sceneset.throatVisible
                                            }
                                            sceneModel.setProperty(model.index, "state", !model.state)
                                        }

                                    }
                                }
                            }

                            Rectangle{
                                width: 100
                                height: 1
                                color: text3dcolor
                                visible: (sceneModel.count>=1) ? true:false
                            }

                            ListView{
                                //                            anchors.verticalCenter: parent.verticalCenter
                                height: scene2dModel.count * 50
                                spacing: 5
                                width: 40
                                interactive: false
                                model: scene2dModel
                                delegate: Rectangle {
                                    id: scene2dRect
                                    width: 120
                                    height: 40
                                    radius: 20
                                    color: (model.state) ? text3dcolor.replace("#", "#50"):"transparent"
                                    Text {
                                        id: scene2dText
                                        anchors.centerIn: parent
                                        font.family: "Helvetica"
                                        font.pixelSize: 16
                                        font.weight: Font.Light
                                        color: text3dcolor
                                        opacity: 1
                                        text: model.name
                                    }
                                    MouseArea{
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onEntered: {
                                            cursorShape = Qt.PointingHandCursor
                                        }
                                        onExited: {
                                            cursorShape = Qt.ArrowCursor
                                        }
                                        onClicked: {
                                            if (model.state){
                                                scene2dModel.setProperty(model.index, "state", false)
                                            }else{
                                                scene2dModel.setProperty(model.index, "state", true)
                                            }
                                            if (model.name === "2D Image"){
                                                main2dimage.visible = !main2dimage.visible
                                            }else if (model.name === "2D Denoise"){
                                                denoise2dimage.visible = !denoise2dimage.visible
                                            }else if (model.name === "2D Filter"){
                                                filter2dimage.visible = !filter2dimage.visible
                                            }else if (model.name === "2D Segment"){
                                                segment2dimage.visible = !segment2dimage.visible
                                            }else if (model.name === "2D Reconstruct"){
                                                reconstruct2dimage.visible = !reconstruct2dimage.visible
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Row{
                            id: poreMat
                            anchors.top: parent.top
                            anchors.topMargin: 10
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 10
//                            visible: (sceneModel.count>=1 && inputdata !== "Synthetic Network") ? true:false
                            visible: {
                                if (sceneModel.count>=1){
                                    if (inputdata !== "Synthetic Network"){
                                        if (inputdata === "3D Gray" || inputdata === "3D Binary"){
                                            return true
                                        }else{
                                            if (reconstruct_image){
                                                return true
                                            }else{
                                                return false
                                            }
                                        }
                                    }else{
                                        return false
                                    }
                                }else{
                                    return false
                                }
                            }

                            property bool isMatrix: true

                            signal changePoreMatrix

                            onChangePoreMatrix: {
                                if (inputdata === "3D Gray" || inputdata === "3D Binary"){
                                    sceneset.source1 = ""
                                    sceneset.source1 = "file:///" + offlineStoragePath + "/main.stl"
                                }
                                if (findbyNameBool(sceneModel, "3D Reconstruct")){
                                    sceneset.source2 = ""
                                    sceneset.source2 = "file:///" + offlineStoragePath + "/reconstruct.stl"
                                }
                            }

                            Component.onCompleted: MainPython.changePM.connect(changePoreMatrix)

                            RadioButton{
                                id: matrix
                                checked: true
                                text: "Grain Space"
                                contentItem: Text {
                                    text: matrix.text
                                    color: text3dcolor
                                    font.pixelSize: 16
                                    leftPadding: matrix.indicator.width + matrix.spacing
                                    verticalAlignment: Text.AlignVCenter
                                }
                                onClicked: {
                                    if (!poreMat.isMatrix){
                                        MainPython.changePoreMatrix()
                                        poreMat.isMatrix = !poreMat.isMatrix
                                    }
                                }
                            }
                            RadioButton{
                                id: pore
                                text: "Pore Space"
                                contentItem: Text {
                                    text: pore.text
                                    color: text3dcolor
                                    font.pixelSize: 16
                                    leftPadding: pore.indicator.width + pore.spacing
                                    verticalAlignment: Text.AlignVCenter
                                }
                                onClicked: {
                                    if (poreMat.isMatrix){
                                        MainPython.changePoreMatrix()
                                        poreMat.isMatrix = !poreMat.isMatrix
                                    }
                                }
                            }
                        }

                        Column{
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.topMargin: 10
                            //                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 5
                            visible: (findbyNameBool(sceneModel, "3D Network")) ? true:false

                            CheckBox{
                                id: netpore
                                checked: true
                                text: "Network Pore"
                                contentItem: Text {
                                    text: netpore.text
                                    color: text3dcolor
                                    font.pixelSize: 16
                                    leftPadding: netpore.indicator.width + netpore.spacing
                                    verticalAlignment: Text.AlignVCenter
                                }
                                onCheckStateChanged: {
                                    sceneset.poreVisible = !sceneset.poreVisible
                                }
                            }
                            Rectangle{
                                width: parent.width
                                height: 20
                                color: "transparent"

                                Row {
                                    anchors.fill: parent

                                    Label{
                                        width: parent.width * 0.4
                                        height: parent.height
                                        verticalAlignment: Qt.AlignVCenter
                                        horizontalAlignment: Qt.AlignHCenter
                                        font.pixelSize: Qt.application.font.pixelSize * 1.5
                                        color: text3dcolor
                                        text: "Color:"
                                    }

                                    Rectangle{
                                        width: parent.width * 0.5
                                        height: parent.height
                                        color: poreColorDialog.color
                                        //-- color picker --//
                                        ColorDialog {
                                            id: poreColorDialog
                                            currentColor: "#0000ff"
                                            color: "#0000ff"

                                            onColorChanged: {
                                                sceneset.poreColor = color
                                            }
                                        }

                                        MouseArea{
                                            anchors.fill: parent
                                            onClicked: {
                                                poreColorDialog.open()
                                            }
                                        }
                                    }

                                }
                            }

                            Rectangle{
                                width: parent.width
                                height: 20
                                color: "transparent"

                                Row {
                                    anchors.fill: parent

                                    Label{
                                        width: parent.width * 0.4
                                        height: parent.height
                                        verticalAlignment: Qt.AlignVCenter
                                        horizontalAlignment: Qt.AlignHCenter
                                        font.pixelSize: Qt.application.font.pixelSize * 1.5
                                        color: text3dcolor
                                        text: "Scale:"
                                    }

                                    Slider{
                                        width: parent.width * 0.5
                                        height: parent.height
                                        from: 0
                                        to: 10
                                        value: 1
                                        onValueChanged: {
                                            sceneset.poreScale = value
                                        }
                                    }
                                }
                            }

                            Rectangle{
                                width: parent.width * 0.9
                                height: 1
                                color: text3dcolor
                            }

                            CheckBox{
                                id: netthroat
                                text: "Network Throat"
                                checked: true
                                contentItem: Text {
                                    text: netthroat.text
                                    color: text3dcolor
                                    font.pixelSize: 16
                                    leftPadding: netthroat.indicator.width + netthroat.spacing
                                    verticalAlignment: Text.AlignVCenter
                                }
                                onCheckStateChanged: {
                                    sceneset.throatVisible = !sceneset.throatVisible
                                }
                            }
                            Rectangle{
                                width: parent.width
                                height: 20
                                color: "transparent"

                                Row {
                                    anchors.fill: parent

                                    Label{
                                        width: parent.width * 0.4
                                        height: parent.height
                                        verticalAlignment: Qt.AlignVCenter
                                        horizontalAlignment: Qt.AlignHCenter
                                        font.pixelSize: Qt.application.font.pixelSize * 1.5
                                        color: text3dcolor
                                        text: "Color:"
                                    }

                                    Rectangle{
                                        width: parent.width * 0.5
                                        height: parent.height
                                        color: throatColorDialog.color
                                        //-- color picker --//
                                        ColorDialog {
                                            id: throatColorDialog
                                            currentColor: "#ff0000"
                                            color: "#ff0000"

                                            onColorChanged: {
                                                sceneset.throatColor = color
                                            }
                                        }
                                        MouseArea{
                                            anchors.fill: parent
                                            onClicked: {
                                                throatColorDialog.open()
                                            }
                                        }
                                    }
                                }
                            }

                            Rectangle{
                                width: parent.width
                                height: 20
                                color: "transparent"

                                Row {
                                    anchors.fill: parent

                                    Label{
                                        width: parent.width * 0.4
                                        height: parent.height
                                        verticalAlignment: Qt.AlignVCenter
                                        horizontalAlignment: Qt.AlignHCenter
                                        font.pixelSize: Qt.application.font.pixelSize * 1.5
                                        color: text3dcolor
                                        text: "Scale:"
                                    }

                                    Slider{
                                        width: parent.width * 0.5
                                        height: parent.height
                                        from: 0
                                        to: 10
                                        value: 1
                                        onValueChanged: {
                                            sceneset.throatScale = value
                                        }
                                    }
                                }
                            }
                        }

                        Row{
                            anchors.left: parent.left
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 30
                            anchors.leftMargin: 10
                            spacing: 5
                            Rectangle{
                                id: textRec
                                border.color: "black"
                                border.width: 1
                                width: 25
                                height: width
                                radius: width/2
                                color: "transparent"
                                Label{
                                    id:texttxt

                                    anchors.fill: parent

                                    text: Icons.format_color_highlight

                                    font.family: webfont.name
                                    font.pixelSize: 15//Qt.application.font.pixelSize
                                    minimumPixelSize: 10
                                    fontSizeMode: Text.Fit

                                    horizontalAlignment: Qt.AlignHCenter
                                    verticalAlignment: Qt.AlignVCenter

                                    color: text3dcolor
                                }
                                ColorDialog {
                                    id: textColorDialog

                                    onColorChanged: {
                                        text3dcolor = color
                                    }
                                }

                                MouseArea{
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onEntered:{
                                        cursorShape = Qt.PointingHandCursor
                                        text_tooltip.visible = true
                                    }
                                    onExited:{
                                        cursorShape = Qt.ArrowCursor
                                        text_tooltip.visible = false
                                    }
                                    onClicked: {
                                        textColorDialog.open()
                                    }
                                }

                                ToolTip {
                                    id: text_tooltip
                                    parent: bcRec
                                    text: "Text color"
                                    delay: 1
                                    font.pixelSize: Qt.application.font.pixelSize
                                }
                            }
                            Rectangle{
                                id: bcRec
                                border.color: "black"
                                border.width: 1
                                width: 25
                                height: width
                                radius: width/2
                                color: "transparent"
                                Label{
                                    id:bctxt

                                    anchors.fill: parent

                                    text: Icons.format_color_fill

                                    font.family: webfont.name
                                    font.pixelSize: 15//Qt.application.font.pixelSize
                                    minimumPixelSize: 10
                                    fontSizeMode: Text.Fit

                                    horizontalAlignment: Qt.AlignHCenter
                                    verticalAlignment: Qt.AlignVCenter

                                    color: text3dcolor
                                }
                                ColorDialog {
                                    id: bcColorDialog
                                    currentColor: Qt.rgba(25/255, 51/255, 77/255, 1)
                                    color: Qt.rgba(25/255, 51/255, 77/255, 1)

                                    onColorChanged: {
                                        view3d.color = color
                                    }
                                }

                                MouseArea{
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onEntered:{
                                        cursorShape = Qt.PointingHandCursor
                                        m_tooltip.visible = true
                                    }
                                    onExited:{
                                        cursorShape = Qt.ArrowCursor
                                        m_tooltip.visible = false
                                    }
                                    onClicked: {
                                        bcColorDialog.open()
                                    }
                                }

                                ToolTip {
                                    id: m_tooltip
                                    parent: bcRec
                                    text: "Background color"
                                    delay: 1
                                    font.pixelSize: Qt.application.font.pixelSize
                                }
                            }
                            Rectangle{
                                id: screenRec
                                border.color: "black"
                                border.width: 1
                                width: 25
                                height: width
                                radius: width/2
                                color: "transparent"
                                Label{
                                    id:capturetxt

                                    anchors.fill: parent

                                    text: Icons.camera

                                    font.family: webfont.name
                                    font.pixelSize: 15//Qt.application.font.pixelSize
                                    minimumPixelSize: 10
                                    fontSizeMode: Text.Fit

                                    horizontalAlignment: Qt.AlignHCenter
                                    verticalAlignment: Qt.AlignVCenter

                                    color: text3dcolor
                                }

                                MouseArea{
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onEntered:{
                                        cursorShape = Qt.PointingHandCursor
                                        m_tooltip2.visible = true
                                    }
                                    onExited:{
                                        cursorShape = Qt.ArrowCursor
                                        m_tooltip2.visible = false
                                    }
                                    onClicked: {
                                        fileSave4.open()
                                    }
                                }

                                ToolTip {
                                    id: m_tooltip2
                                    parent: screenRec
                                    text: "Take screenshot"
                                    delay: 1
                                    font.pixelSize: Qt.application.font.pixelSize
                                }
                            }
                        }
                    }


                    // -- Curves --//
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "#1e1f27"
                        ChartBarModule{
                            id: psdchart
                            anchors.bottomMargin: 10
                            title: "Pore Size Distribution"
                            yTitle: "Relative frequency"
                            barxTitle: "Pore Size (Micron)"
                            xData: porexData.join(",").split(",")
                            yData: poreyData.join(",").split(",")
                        }
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "#1e1f27"
                        ChartBarModule{
                            id: gsdchart
                            anchors.bottomMargin: 10
                            title: "Grain Size Distribution"
                            barxTitle: "Grain Size (Micron)"
                            yTitle: "Relative frequency"
                            xData: grainxData.join(",").split(",")
                            yData: grainyData.join(",").split(",")
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "#1e1f27"
                        ChartLineModule{
                            id: s2chart
                            anchors.bottomMargin: 10
                            title: "Two point Correlation function"
                            xTitle: "Radial distance (pixels)"
                            yTitle: "Auto-correlation function, S2"
                            xData: s2_x.join(",").split(",")
                            yData: s2_y.join(",").split(",")
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "#1e1f27"

                        ChartLineModule{
                            id: psdnet
                            anchors.bottomMargin: 10
                            title: "Pore Size Distribution"
                            xTitle: "Pore Size (Micron)"
                            yTitle: "Relative frequency"
                            xData: psdxData.join(",").split(",")
                            yData: psdyData.join(",").split(",")
                        }
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "#1e1f27"

                        ChartLineModule{
                            id: tsdnet
                            anchors.bottomMargin: 10
                            title: "Throat Size Distribution"
                            xTitle: "Throat Size (Micron)"
                            yTitle: "Relative frequency"
                            xData: tsdxData.join(",").split(",")
                            yData: tsdyData.join(",").split(",")
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "#1e1f27"

                        ChartBarModule{
                            id: coordchart
                            anchors.bottomMargin: 10
                            title: "Coordination number"
                            barxTitle: "Coordination number"
                            yTitle: "Frequency"
                            xData: coordxData.join(",").split(",")
                            yData: coordyData.join(",").split(",")
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "#1e1f27"
                        ChartpcModule{
                            id: pcchart
                            anchors.bottomMargin: 10
                            title: "Capillary pressure"
                            xTitle: "SW (%)"
                            yTitle: "Pc (Pascal)"
                            xData1: pcswxData.join(",").split(",")
                            yData1: pcxData.join(",").split(",")
                            xData2: pcswyData.join(",").split(",")
                            yData2: pcyData.join(",").split(",")
                            xData3: pcswzData.join(",").split(",")
                            yData3: pczData.join(",").split(",")
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "#1e1f27"
                        ChartRelModule{
                            id: krchart
                            anchors.bottomMargin: 10
                            title: "Relative permeability"
                            xTitle: "SW (%)"
                            yTitle: "Kr"
                            name1: "krw_x"
                            xData1: krswxData.join(",").split(",")
                            yData1: krwxData.join(",").split(",")
                            name2: "krnw_x"
                            xData2: krswxData.join(",").split(",")
                            yData2: krnwxData.join(",").split(",")
                            name3: "krw_y"
                            xData3: krswyData.join(",").split(",")
                            yData3: krwyData.join(",").split(",")
                            name4: "krnw_y"
                            xData4: krswyData.join(",").split(",")
                            yData4: krnwyData.join(",").split(",")
                            name5: "krw_z"
                            xData5: krswzData.join(",").split(",")
                            yData5: krwzData.join(",").split(",")
                            name6: "krnw_z"
                            xData6: krswzData.join(",").split(",")
                            yData6: krnwzData.join(",").split(",")
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "#1e1f27"
                        ChartRelModule{
                            id: drchart
                            anchors.bottomMargin: 10
                            title: "Relative diffusivity"
                            xTitle: "SW (%)"
                            yTitle: "Dr"
                            name1: "drw_x"
                            xData1: drswxData.join(",").split(",")
                            yData1: drwxData.join(",").split(",")
                            name2: "drnw_x"
                            xData2: drswxData.join(",").split(",")
                            yData2: drnwxData.join(",").split(",")
                            name3: "krw_y"
                            xData3: drswyData.join(",").split(",")
                            yData3: drwyData.join(",").split(",")
                            name4: "krnw_y"
                            xData4: drswyData.join(",").split(",")
                            yData4: drnwyData.join(",").split(",")
                            name5: "krw_z"
                            xData5: drswzData.join(",").split(",")
                            yData5: drwzData.join(",").split(",")
                            name6: "krnw_z"
                            xData6: drswzData.join(",").split(",")
                            yData6: drnwzData.join(",").split(",")
                        }
                    }
                }
            }

            // -- Timer ans Stop Burron -- //
            Rectangle{
                id: footer
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                color: "#a9a9a9"

                Row{
                    anchors.fill: parent
                    // **** spacer ****//
                    Rectangle{
                        width: parent.width *0.1
                        height: parent.height
                        color: "#a9a9a9"
                    }
                    Rectangle{
                        height: width
                        width: parent.width *0.1
                        radius: width/2
                        color: "#a9a9a9"
                        anchors.verticalCenter: parent.verticalCenter
                        Label{
                            id: timer
                            anchors.fill: parent
                            bottomPadding: 10
                            verticalAlignment: Qt.AlignVCenter
                            horizontalAlignment: Qt.AlignHCenter

                            font.pixelSize: Qt.application.font.pixelSize * 1.7
                            text: "00:00"
                        }
                    }

                    // **** spacer ****//
                    Rectangle{
                        width: parent.width * 0.225
                        height: parent.height
                        color: "#a9a9a9"
                    }

                    Rectangle{
                        id: btn_state
                        height: width
                        width: parent.width *0.15
                        radius: width/2
                        anchors.verticalCenter: parent.verticalCenter
                        property bool btnstate: false
                        enabled: btn_state.btnstate ? true : false

                        border.width: btn_state.activeFocus ? 2 : 1
                        border.color: "#888"
                        //                            radius: 4
                        gradient: Gradient {
                            GradientStop { position: 0 ; color: btn_state.pressed ? "#ccc" : "#eee" }
                            GradientStop { position: 1 ; color: btn_state.pressed ? "#aaa" : "#ccc" }
                        }
                        //                        palette {
                        //                            button: btn_state.btnstate ? "#aaddaa" : "#dc143c"
                        //                        }
                        Label{
                            id: btn_text
                            anchors.fill: parent

                            font.pixelSize: Qt.application.font.pixelSize * 1.7
                            text: "Stop"
                            bottomPadding: 10
                            verticalAlignment: Qt.AlignVCenter
                            horizontalAlignment: Qt.AlignHCenter
                        }
                        MouseArea{
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: {
                                cursorShape = Qt.PointingHandCursor
                            }
                            onExited: {
                                cursorShape = Qt.ArrowCursor
                            }
                            onClicked: {
                                MainPython.endProcess()
                                btn_state.btnstate = !btn_state.btnstate
                            }
                        }
                    }

                    // **** spacer ****//
                    Rectangle{
                        width: parent.width *0.225
                        height: parent.height
                        color: "#a9a9a9"
                    }
                    Rectangle{
                        height: width
                        width: parent.width *0.1
                        radius: width/2
                        color: "#a9a9a9"
                        anchors.verticalCenter: parent.verticalCenter
                        Label{
                            id: percent
                            anchors.fill: parent
                            bottomPadding: 10
                            verticalAlignment: Qt.AlignVCenter
                            horizontalAlignment: Qt.AlignHCenter
                            font.pixelSize: Qt.application.font.pixelSize * 1.7
                            text: "0%"
                        }
                    }
                    // **** spacer ****//
                    Rectangle{
                        width: parent.width *0.1
                        height: parent.height
                        color: "#a9a9a9"
                    }
                }
            }
        }

        //-- Right Panel --//
        DockItem{
            id: resultview
            sResultview: 0
            Layout.preferredWidth:  parent.width * 0.2
            Layout.fillHeight: true
        }

        //-- Right transition butoon --//
        Button{
            id: open_result
            Layout.fillHeight: true
            Layout.preferredWidth: 20
            palette {
                button: "#808080"
            }
            Label{
                anchors.fill: parent

                font.family: webfont.name
                font.pixelSize: Qt.application.font.pixelSize * 1.7
                text: resultview.expand ? Icons.arrow_left_box : Icons.arrow_right_box
                verticalAlignment: Qt.AlignVCenter
            }
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    resultview.expand = !resultview.expand

                    if (expand === true){
                        expand = !expand
                    }
                }
            }
        }
    }

    //-- right Animation --//
    SequentialAnimation{
        id: animationdynamicpop
        PropertyAnimation { target: successDynamicPop ; properties: "width"; to: 300 ; duration: 200 }
        PauseAnimation { duration: 1500 }
        PropertyAnimation { target: successDynamicPop ; properties: "width"; to: 0 ; duration: 100 }
    }

    AcceptDynamicPop{
        id: successDynamicPop
        width: 0
        height: 60
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: 10
    }

    //-- License form --//
    LicenseForm{
        id: licenseform

        visible: !isLicensed

        //flags: Qt.Dialog //SplashScreen //Dialog

    }

    //-- Trial form --//
    TrialForm{
        id: trialform

        visible: false

        //flags: Qt.Dialog //SplashScreen //Dialog

    }

    //-- License form --//
    PurchaseLicenseForm{
        id: purchaseform

        visible: false

        //flags: Qt.Dialog //SplashScreen //Dialog

    }


    //-- 2D image setting --//
    property var image2d_filter: ApplicationWindow{
        id: image2d_filter

        //-- triger when all instrument loaded --//
        signal allInstrumentLoaded()

        title: "2D image"
        visible: false
        width: 400
        height: 500
        minimumWidth: 200
        minimumHeight: 300

        //flags: Qt.Dialog //SplashScreen //Dialog

        Material.theme: Material.Dark

        background: Rectangle{ color: "#535353" }

        Input2dDataSetting{
            id: image2Ditem
            anchors.fill: parent
        }

    }

    //-- 3D image setting --//
    property var image_filter: ApplicationWindow{
        id: image_filter

        //-- triger when all instrument loaded --//
        signal allInstrumentLoaded()

        title: "3D image"
        visible: false
        width: 400
        height: 500
        minimumWidth: 200
        minimumHeight: 300

        //flags: Qt.Dialog //SplashScreen //Dialog

        Material.theme: Material.Dark

        background: Rectangle{ color: "#535353" }

        InputDataSetting{
            id: image3Ditem
            anchors.fill: parent
        }

    }

    //-- 2D main images --//
    property var main2dimages: ApplicationWindow{
        id: main2dimage

        title: "2D main images"
        visible: false
        width: xdim
        height: ydim
        minimumWidth: xdim
        minimumHeight: ydim

        //flags: Qt.Dialog //SplashScreen //Dialog

        Material.theme: Material.Dark

        background: Rectangle{ color: "#535353" }

        Display2dImages{
            anchors.fill: parent
            visible: main2dimage.visible
            imageNum: zdim
            imageType: "MImages"
        }

        onClosing: {
            main2dimage.visible = false
            var index = findbyName(scene2dModel, "2D Image")
            scene2dModel.setProperty(index, "state", false)
        }
    }

    //-- 2D denoised images --//
    property var denoise2dimages: ApplicationWindow{
        id: denoise2dimage

        title: "2D denoised images"
        visible: false
        width: xdim
        height: ydim
        minimumWidth: xdim
        minimumHeight: ydim

        //flags: Qt.Dialog //SplashScreen //Dialog

        Material.theme: Material.Dark

        background: Rectangle{ color: "#535353" }

        Display2dImages{
            anchors.fill: parent
            visible: denoise2dimage.visible
            imageNum: zdim
            imageType: "DImages"
        }
        onClosing: {
            var index = findbyName(scene2dModel, "2D Denoise")
            scene2dModel.setProperty(index, "state", false)
        }
    }

    //-- 2D filtered images --//
    property var filter2dimages: ApplicationWindow{
        id: filter2dimage

        title: "2D filtered images"
        visible: false
        width: xdim
        height: ydim
        minimumWidth: xdim
        minimumHeight: ydim

        //flags: Qt.Dialog //SplashScreen //Dialog

        Material.theme: Material.Dark

        background: Rectangle{ color: "#535353" }

        Display2dImages{
            anchors.fill: parent
            visible: filter2dimage.visible
            imageNum: zdim
            imageType: "FImages"
        }
        onClosing: {
            var index = findbyName(scene2dModel, "2D Filter")
            scene2dModel.setProperty(index, "state", false)
        }
    }

    //-- 2D segmented images --//
    property var segment2dimages: ApplicationWindow{
        id: segment2dimage

        title: "2D segmented images"
        visible: false
        width: xdim
        height: ydim
        minimumWidth: xdim
        minimumHeight: ydim

        //flags: Qt.Dialog //SplashScreen //Dialog

        Material.theme: Material.Dark

        background: Rectangle{ color: "#535353" }

        Display2dImages{
            anchors.fill: parent
            visible: segment2dimage.visible
            imageNum: zdim
            imageType: "SImages"
        }
        onClosing: {
            var index = findbyName(scene2dModel, "2D Segment")
            scene2dModel.setProperty(index, "state", false)
        }
    }

    //-- 2D reconstructed images --//
    property var reconstruct2dimages: ApplicationWindow{
        id: reconstruct2dimage

        title: "2D reconstructed images"
        visible: false
        width: xdim
        height: ydim
        minimumWidth: xdim
        minimumHeight: ydim

        //flags: Qt.Dialog //SplashScreen //Dialog

        Material.theme: Material.Dark

        background: Rectangle{ color: "#535353" }

        Display2dImages{
            anchors.fill: parent
            visible: reconstruct2dimage.visible
            imageNum: zdimReconstruct
            imageType: "RImages"
        }
        onClosing: {
            var index = findbyName(scene2dModel, "2D Reconstruct")
            scene2dModel.setProperty(index, "state", false)
        }
    }

    FileDialog {
        id: fileDialog
        visible: false
        title: "Please choose a file"
//        folder: shortcuts.home
        nameFilters: [ "Image files (*.tif *.jpg *.png)", "All files (*)" ]

        onAccepted: {
            //            console.log("You chose: " + fileDialog.fileUrl)
            //            getImagedata(fileDialog.fileUrl)
            var path = fileDialog.file.toString()
            path = path.replace(/^(file:\/{3})|(qrc:\/{2})|(http:\/{2})/,"")
            image2Ditem.fileurl = path
            image2d_filter.visible = true
        }
        onRejected: {
            console.log("Canceled")
        }
    }

    FileDialog {
        id: fileDialog_3D
        visible: false
        title: "Please choose a file"
//        folder: shortcuts.home
        nameFilters: [ "Image files (*.tif *.jpg *.png)", "All files (*)" ]

        onAccepted: {
            //            console.log("You chose: " + fileDialog.fileUrl)
            //            getImagedata(fileDialog.fileUrl)
            var path = fileDialog_3D.file.toString()
            path = path.replace(/^(file:\/{3})|(qrc:\/{2})|(http:\/{2})/,"")
            image3Ditem.fileurl = path
            image_filter.visible = true
        }
        onRejected: {
            console.log("Canceled")
        }

    }

    FileDialog {
        id: fileOpen
        visible: false
        title: "Please choose a file to open"
//        folder: shortcuts.home
        nameFilters: [ "PoroX files (*.prx)"]

        onAccepted: {
            var path = fileOpen.file.toString()
            path = path.replace(/^(file:\/{3})|(qrc:\/{2})|(http:\/{2})/,"")
            MainPython.open_file(path)
        }
        onRejected: {
            console.log("Canceled")
        }

    }

    FileDialog {
        id: fileSave
        visible: false
//        title: "Please choose a folder"
//        folder: shortcuts.home
        nameFilters: [ "PoroX files (*.prx)", "All files (*)" ]
        fileMode: FileDialog.SaveFile

        onAccepted: {
            var path = fileSave.file.toString()
            path = path.replace(/^(file:\/{3})|(qrc:\/{2})|(http:\/{2})/,"")
            savePath = path
            MainPython.save_file(path)
        }
        onRejected: {
            console.log("Canceled")
        }

    }

    FileDialog {
        id: fileSave2
        visible: false
//        title: "Please choose a folder"
//        folder: shortcuts.home
        nameFilters: [ "PoroX files (*.prx)", "All files (*)" ]
        fileMode: FileDialog.SaveFile

        onAccepted: {
            var path = fileSave2.file.toString()
            path = path.replace(/^(file:\/{3})|(qrc:\/{2})|(http:\/{2})/,"")
            savePath = path
            MainPython.save_file(path)
            quitPop.visible = true

        }
        onRejected: {
            console.log("Canceled")
            quitPop.visible = true
        }

    }

    FileDialog {
        id: fileSave3
        visible: false
//        title: "Please choose a folder"
//        folder: shortcuts.home
        nameFilters: [ "PoroX files (*.prx)", "All files (*)" ]
        fileMode: FileDialog.SaveFile

        onAccepted: {
            var path = fileSave3.file.toString()
            path = path.replace(/^(file:\/{3})|(qrc:\/{2})|(http:\/{2})/,"")
            savePath = path
            MainPython.save_file(path)
            MainPython.new_file()
        }
        onRejected: {
            MainPython.new_file()
        }

    }

    FileDialog {
        id: fileSave4
        visible: false
        title: "Save screenshot As"
        nameFilters: [ "png files (*.png)", "jpg files (*.jpg)", "All files (*)" ]
        fileMode: FileDialog.SaveFile

        onAccepted: {
            var path = fileSave4.file.toString()
            path = path.replace(/^(file:\/{3})|(qrc:\/{2})|(http:\/{2})/,"")
            saveScreenpath = path
            msg = sceneset.requestRenderCapture()
            msg.completed.connect(saveImage)
        }
        onRejected: {
            fileSave4.close()
        }

    }

    FilePanel{
        id: filepanel
        anchors.left: parent.left
        anchors.top: header_rec.bottom
        visible: false

        clip: true
        width: 0
        height: parent.height - header_rec.height

        color: "#444444"
    }

    onClosing: {
        close.accepted = false
        if (filepanel.saveEnable){
            savefilePop.visible = true
        }else{
            quitPop.visible = true
        }
    }

    Quit_Popup{
        id: quitPop
        visible: false
        width: 350 * ratio * sizeRatio
        height: 181 * ratio * sizeRatio

        bodyText_Dialog: "Are you sure you want to exit?"

        x: (main1.width / 2) -(width / 2) - 10
        y: (main1.height / 2) - (height / 2) - 30
        onAccept: {
            MainPython.folderDel()
            quitPop.visible = false
            Qt.quit()
        }
        onCancel: {
            quitPop.visible = false
        }
    }

    Accept_Popup{
        id: acceptPop
        visible: false
        width: 350 * ratio * sizeRatio
        height: 181 * ratio * sizeRatio

        x: (main1.width / 2) - (width / 2) - 10
        y: (main1.height / 2) - (height / 2) - 30
        onAccept: {
            acceptPop.visible = false
        }
    }

    Warning_Popup{
        id: warningPop
        visible: false
        width: 350 * ratio * sizeRatio
        height: 181 * ratio * sizeRatio

        x: (main1.width / 2) - (width / 2) - 10
        y: (main1.height / 2) - (height / 2) - 30
        onAccept: {
            warningPop.visible = false
        }
    }

    Error_Popup{
        id: errorPop
        visible: false
        width: 350 * ratio * sizeRatio
        height: 181 * ratio * sizeRatio

        x: (main1.width / 2) - (width / 2) - 10
        y: (main1.height / 2) - (height / 2) - 30
        onAccept: {
            errorPop.visible = false
        }
    }

    Newfile_Popup{
        id: newfilePop
        visible: false
        width: 350 * ratio * sizeRatio
        height: 181 * ratio * sizeRatio

        x: (main1.width / 2) -(width / 2) - 10
        y: (main1.height / 2) - (height / 2) - 30
        onAccept: {
            if (filepanel.saveEnable){
                savefilePop2.visible = true
                newfilePop.visible = false
            }else{
                MainPython.new_file()
                newfilePop.visible = false
            }
        }
        onCancel: {
            newfilePop.visible = false
        }
    }

    Save_Popup{
        id: savefilePop
        visible: false
        width: 350 * ratio * sizeRatio
        height: 181 * ratio * sizeRatio

        x: (main1.width / 2) -(width / 2) - 10
        y: (main1.height / 2) - (height / 2) - 30
        onAccept: {
            savefilePop.visible = false
            fileSave2.visible = true
        }
        onCancel: {
            savefilePop.visible = false
            quitPop.visible = true
        }
    }

    Save_Popup{
        id: savefilePop2
        visible: false
        width: 350 * ratio * sizeRatio
        height: 181 * ratio * sizeRatio

        x: (main1.width / 2) -(width / 2) - 10
        y: (main1.height / 2) - (height / 2) - 30
        onAccept: {
            if (savePath === ""){
                fileSave3.visible = true
                savefilePop2.visible = false
            }else{
                MainPython.save_file(savePath)
                MainPython.new_file()
                savefilePop2.visible = false
            }
        }
        onCancel: {
            MainPython.new_file()
            savefilePop2.visible = false
        }
    }

    //-- setting windows --//
    Popup {
        id: popup_aboutUs

        width: txa_about.implicitWidth * 1.4
        height: txa_about.implicitHeight * 4

        x: (main1.width / 2) - (width / 2) - 10
        y: (main1.height / 2) - (height / 2) - 30

        //            modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        padding: 0
        topPadding: 0

        background: Rectangle{
            color: "#535353"
            border.color: "#707070"
            radius: 3
        }

        TextArea{
            id: txa_about
            anchors.centerIn: parent
            text: "Sharif University of Technology software developers"
            readOnly: true
            color: "#dddddd"
        }

    }


    function find(model, criteria) {
        for(var i = 0; i < model.count; ++i) if (model.get(i).text === criteria) return i
        return null
    }

    function findbyName(model, criteria) {
        for(var i = 0; i < model.count; ++i) if (model.get(i).name === criteria) return i
        return null
    }

    function findbyNameBool(model, criteria) {
        for(var i = 0; i < model.count; ++i) if (model.get(i).name === criteria) return true
        return false
    }

    function findBoolean(model, criteria) {
        for(var i = 0; i < model.count; ++i) if (model.get(i).text === criteria) return true
        return false
    }

    function findprops(model, criteria) {
        for(var i = 0; i < model.count; ++i) if (model.get(i).maintext === criteria) return i
        return null
    }

    function checkprops(){
        helpmodel.clear()
        if (porediam){
            if(porediamType==="Weibull" || porediamType==="Normal" || porediamType==="Generic-distribution"){
                if (!findBoolean(helpmodel, "pore.seed") && !poreseed){
                    helpmodel.append({
                                         "text": "pore.seed",
                                         "check": poreseed
                                     })
                }
            }else if (porediamType==="From-neighbor-throats"){
                if (!findBoolean(helpmodel, "throat.seed") && !throatseed){
                    helpmodel.append({
                                         "text": "throat.seed",
                                         "check": throatseed
                                     })
                }
            }
        }


        if (porearea || porevol){
            if (!findBoolean(helpmodel, "pore.diameter") && !porediam){
                helpmodel.append({
                                     "text": "pore.diameter",
                                     "check": porediam
                                 })
            }
        }

        if (throatdiam){
            if(throatdiamType==="Weibull" || throatdiamType==="Normal" || throatdiamType==="Generic_distribution"){
                if(!findBoolean(helpmodel, "throat.seed") && !throatseed){
                    helpmodel.append({
                                         "text": "throat.seed",
                                         "check": throatseed
                                     })
                }
            }else if (throatdiamType==="Equivalent_diameter"){
                if (!findBoolean(helpmodel, "throat.area") && !throatarea){
                    helpmodel.append({
                                         "text": "throat.area",
                                         "check": throatarea
                                     })
                }
            }else if (throatdiamType==="From_neighbor_pores"){
                if (!findBoolean(helpmodel, "pore.seed") && !poreseed){
                    helpmodel.append({
                                         "text": "pore.seed",
                                         "check": poreseed
                                     })
                }
            }
        }


        if (throatarea){
            if (!findBoolean(helpmodel, "throat.diameter") && !throatdiam){
                helpmodel.append({
                                     "text": "throat.diameter",
                                     "check": throatdiam
                                 })
            }
        }

        if(poresurf){
            if (!findBoolean(helpmodel, "pore.diameter") && !porediam){
                helpmodel.append({
                                     "text": "pore.diameter",
                                     "check": porediam
                                 })
            }
            if (!findBoolean(helpmodel, "throat.area") && !throatarea){
                helpmodel.append({
                                     "text": "throat.area",
                                     "check": throatarea
                                 })
            }
        }

        if (throatperim){
            if (!findBoolean(helpmodel, "throat.diameter") && !throatdiam){
                helpmodel.append({
                                     "text": "throat.diameter",
                                     "check": throatdiam
                                 })
            }
        }

        if(throatsurf){
            if(throatsurfType==="Cylinder" || throatsurfType==="Cuboid"){
                if(!findBoolean(helpmodel, "throat.diameter") && !throatdiam){
                    helpmodel.append({
                                         "text": "throat.diameter",
                                         "check": throatdiam
                                     })
                }
                if(!findBoolean(helpmodel, "throat.length") && !throatlength){
                    helpmodel.append({
                                         "text": "throat.length",
                                         "check": throatlength
                                     })
                }
            }else if (throatsurfType==="Extrusion"){
                if(!findBoolean(helpmodel, "throat.perimeter") && !throatperim){
                    helpmodel.append({
                                         "text": "throat.perimeter",
                                         "check": throatperim
                                     })
                }
                if(!findBoolean(helpmodel, "throat.length") && !throatlength){
                    helpmodel.append({
                                         "text": "throat.length",
                                         "check": throatlength
                                     })
                }
            }else if (throatsurfType==="Rectangle"){
                if(!findBoolean(helpmodel, "throat.length") && !throatlength){
                    helpmodel.append({
                                         "text": "throat.length",
                                         "check": throatlength
                                     })
                }
            }
        }

        if(throatshapefactor){
            if(throatshapefactorType==="Compactness"||throatshapefactorType==="Mason_morrow"){
                if(!findBoolean(helpmodel, "throat.perimeter") && !throatperim){
                    helpmodel.append({
                                         "text": "throat.perimeter",
                                         "check": throatperim
                                     })
                }
                if (!findBoolean(helpmodel, "throat.area") && !throatarea){
                    helpmodel.append({
                                         "text": "throat.area",
                                         "check": throatarea
                                     })
                }
            }else if(throatshapefactorType==="Jenkins_rao"){
                if(!findBoolean(helpmodel, "throat.perimeter") && !throatperim){
                    helpmodel.append({
                                         "text": "throat.perimeter",
                                         "check": throatperim
                                     })
                }
                if (!findBoolean(helpmodel, "throat.area") && !throatarea){
                    helpmodel.append({
                                         "text": "throat.area",
                                         "check": throatarea
                                     })
                }
                if (!findBoolean(helpmodel, "throat.diameter") && !throatdiam){
                    helpmodel.append({
                                         "text": "throat.diameter",
                                         "check": throatdiam
                                     })
                }
            }
        }

        if(throatendpoint){
            if(throatendpointType==="Cubic_pores"||throatendpointType==="Square_pores"){
                if(!findBoolean(helpmodel, "pore.diameter") && !porediam){
                    helpmodel.append({
                                         "text": "pore.diameter",
                                         "check": porediam
                                     })
                }
            }else if(throatendpointType==="Circular_pores"||throatendpointType==="Spherical_pores"){
                if(!findBoolean(helpmodel, "pore.diameter") && !porediam){
                    helpmodel.append({
                                         "text": "pore.diameter",
                                         "check": porediam
                                     })
                }
                if (!findBoolean(helpmodel, "throat.diameter") && !throatdiam){
                    helpmodel.append({
                                         "text": "throat.diameter",
                                         "check": throatdiam
                                     })
                }
                //                            if(!findBoolean(helpmodel, "throat.centroid") && !throatcentroid){
                //                                helpmodel.append({
                //                                                     "text": "throat.centroid",
                //                                                     "check": throatcentroid
                //                                                 })
                //                            }
            }else if(throatendpointType==="Straight_throat"){
                //                            if(!findBoolean(helpmodel, "throat.centroid") && !throatcentroid){
                //                                helpmodel.append({
                //                                                     "text": "throat.centroid",
                //                                                     "check": throatcentroid
                //                                                 })
                //                            }
                if (!findBoolean(helpmodel, "throat.length") && !throatlength){
                    helpmodel.append({
                                         "text": "throat.length",
                                         "check": throatlength
                                     })
                }
                //                            if (!findBoolean(helpmodel, "throat.vector") && !throatvector){
                //                                helpmodel.append({
                //                                                     "text": "throat.vector",
                //                                                     "check": throatvector
                //                                                 })
                //                            }
            }
        }


        if(throatlength){
            if (throatlengthType==="Piecewise"){
                if (!findBoolean(helpmodel, "throat.end points") && !throatendpoint){
                    helpmodel.append({
                                         "text": "throat.end points",
                                         "check": throatendpoint
                                     })
                }
                //                            if(!findBoolean(helpmodel, "throat.centroid") && !throatcentroid){
                //                                helpmodel.append({
                //                                                     "text": "throat.centroid",
                //                                                     "check": throatcentroid
                //                                                 })
                //                            }
            }else if (throatlengthType==="Conduit_lengths"){
                if (!findBoolean(helpmodel, "throat.end points") && !throatendpoint){
                    helpmodel.append({
                                         "text": "throat.end points",
                                         "check": throatendpoint
                                     })
                }
            }else if (throatlengthType==="Classic"){
                if(!findBoolean(helpmodel, "pore.diameter") && !porediam){
                    helpmodel.append({
                                         "text": "pore.diameter",
                                         "check": porediam
                                     })
                }
            }
        }


        if(throatvol){
            if (throatvolType==="Cylinder" || throatvolType==="Cuboid" || throatvolType==="Rectangle"){
                if (!findBoolean(helpmodel, "throat.diameter") && !throatdiam){
                    helpmodel.append({
                                         "text": "throat.diameter",
                                         "check": throatdiam
                                     })
                }
                if (!findBoolean(helpmodel, "throat.length") && !throatlength){
                    helpmodel.append({
                                         "text": "throat.length",
                                         "check": throatlength
                                     })
                }
            }else if (throatvolType==="Extrusion"){
                if (!findBoolean(helpmodel, "throat.area") && !throatarea){
                    helpmodel.append({
                                         "text": "throat.area",
                                         "check": throatarea
                                     })
                }
                if (!findBoolean(helpmodel, "throat.length") && !throatlength){
                    helpmodel.append({
                                         "text": "throat.length",
                                         "check": throatlength
                                     })
                }
            }else if (throatvolType==="Lens" || throatvolType==="Pendular_ring"){
                if (!findBoolean(helpmodel, "throat.diameter") && !throatdiam){
                    helpmodel.append({
                                         "text": "throat.diameter",
                                         "check": throatdiam
                                     })
                }
                if(!findBoolean(helpmodel, "pore.diameter") && !porediam){
                    helpmodel.append({
                                         "text": "pore.diameter",
                                         "check": porediam
                                     })
                }
            }
        }

        if (throatshapefactor){
            if(throatshapefactorType==="Compactness"||throatshapefactorType==="Cuboid"){
                if (!findBoolean(helpmodel, "throat.area") && !throatarea){
                    helpmodel.append({
                                         "text": "throat.area",
                                         "check": throatarea
                                     })
                }
            }else if (throatshapefactorType==="Rectangle"){
                if (!findBoolean(helpmodel, "throat.area") && !throatarea){
                    helpmodel.append({
                                         "text": "throat.area",
                                         "check": throatarea
                                     })
                }
                if (!findBoolean(helpmodel, "throat.diameter") && !throatdiam){
                    helpmodel.append({
                                         "text": "throat.diameter",
                                         "check": throatdiam
                                     })
                }
            }
        }

        if(!findBoolean(helpmodel, "Capillary pressure") && !capillarypressure){
            helpmodel.append({
                                 "text": "Capillary pressure",
                                 "check": capillarypressure
                             })
        }

        if(!findBoolean(helpmodel, "Diffusive conductance") && !diffusivecond){
            helpmodel.append({
                                 "text": "Diffusive conductance",
                                 "check": diffusivecond
                             })
        }

        if(!findBoolean(helpmodel, "Hydraulic conductance") && !hydrauliccond){
            helpmodel.append({
                                 "text": "Hydraulic conductance",
                                 "check": hydrauliccond
                             })
        }

        if(!findBoolean(helpmodel, "Poisson shape factor") && !poissonshapefactor){
            helpmodel.append({
                                 "text": "Poisson shape factor",
                                 "check": poissonshapefactor
                             })
        }

        if (invadedensityType === "Standard"){
            if (!findBoolean(helpmodel, "Invading molar density") && !invademolar){
                helpmodel.append({
                                     "text": "Invading molar density",
                                     "check": invademolar
                                 })
            }
        }

        if (invadediffusivityType === "Tyn_calus" || invadediffusivityType === "Tyn_calus_scaling"){
            if (!findBoolean(helpmodel, "Invading viscosity") && !invadeviscosity){
                helpmodel.append({
                                     "text": "Invading viscosity",
                                     "check": invadeviscosity
                                 })
            }
        }

        if (invademolarType==="Standard"){
            if (!findBoolean(helpmodel, "Invading density") && !invadedensity){
                helpmodel.append({
                                     "text": "Invading density",
                                     "check": invadedensity
                                 })
            }
        }

        if (invadesurfType === "Eotvos"){
            if (!findBoolean(helpmodel, "Invading molar density") && !invademolar){
                helpmodel.append({
                                     "text": "Invading molar density",
                                     "check": invademolar
                                 })
            }
        }

        if (defenddensityType === "Standard"){
            if (!findBoolean(helpmodel, "Defending molar density") && !defendmolar){
                helpmodel.append({
                                     "text": "Defending molar density",
                                     "check": defendmolar
                                 })
            }
        }

        if (defenddiffusivityType === "Tyn_calus" || defenddiffusivityType === "Tyn_calus_scaling"){
            if (!findBoolean(helpmodel, "Defending viscosity") && !defendviscosity){
                helpmodel.append({
                                     "text": "Defending viscosity",
                                     "check": defendviscosity
                                 })
            }
        }

        if (defendmolarType==="Standard"){
            if (!findBoolean(helpmodel, "Defending density") && !defenddensity){
                helpmodel.append({
                                     "text": "Defending density",
                                     "check": defenddensity
                                 })
            }
        }

        if (defendsurfType === "Eotvos"){
            if (!findBoolean(helpmodel, "Defending molar density") && !defendmolar){
                helpmodel.append({
                                     "text": "Defending molar density",
                                     "check": defendmolar
                                 })
            }
        }
    }
}
