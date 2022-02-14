function newFile(){
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

function openFile(){
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

function remainingLicenseTime(expiredTime){
    var remainTime = expiredTime.split("/")
    if (remainTime[1] < 10) remainTime[1] = "0" + remainTime[1]
    if (remainTime[2] < 10) remainTime[2] = "0" + remainTime[2]
    var timeStart = new Date(remainTime[0]+"/"+remainTime[1]+"/"+remainTime[2]);
    var today = new Date();

    var milisec_diff = timeStart - today;

    var days = Math.floor(milisec_diff / 1000 / 60 / (60 * 24));

    var date_diff = new Date( milisec_diff );

    if (days > 0 && days <= 10){
        warningPop.bodyText_Dialog = "Remaining license time: " + days + " days"
        warningPop.visible = true
    }else if(days < 0){
        setting.isLicensed = false
        setting.licenseEmail = ""
        setting.licenseTime = ""
        setting.licenseType = ""
    }

    //        print(days + " Days "+ date_diff.getHours() + " Hours " + date_diff.getMinutes() + " Minutes " + date_diff.getSeconds() + " Seconds")
}
