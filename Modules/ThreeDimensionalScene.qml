import Qt3D.Core 2.15
import Qt3D.Render 2.15
import Qt3D.Input 2.15
import Qt3D.Extras 2.15

//Creating the root scene
Entity {
    id: sceneRoot
    property alias backgroundColor: fRenderer.clearColor

    property alias source1: images.source1
    property alias segmentVisible: images.visible
    property alias x: images.x
    property alias y: images.y
    property alias z: images.z

    property alias source2: images2.source1
    property alias reconstructVisible: images2.visible
    property alias x2: images2.x
    property alias y2: images2.y
    property alias z2: images2.z

    property alias poreModel: images3.pModel
    property alias poreVisible: images3.visible
    property alias poreColor: images3.color
    property alias poreScale: images3.scale
    property alias x3: images3.x
    property alias y3: images3.y
    property alias z3: images3.z

    property alias throatModel: images4.tModel
    property alias throatVisible: images4.visible
    property alias throatColor: images4.color
    property alias throatScale: images4.scale
    property alias x4: images4.x
    property alias y4: images4.y
    property alias z4: images4.z

    function requestRenderCapture()
        {
            return renderCapture.requestCapture()
        }

    //Adding camera
    Camera {
        id: camera
        projectionType: CameraLens.PerspectiveProjection
        fieldOfView: 45
        aspectRatio: 16/9
        nearPlane : 0.01
        farPlane : 100000.0
        position:{
            if (inputdata==="3D Gray"||inputdata==="3D Binary"||inputdata==="Synthetic Network"){
                return Qt.vector3d( 0.0, 0.0, 200+Math.max(x,y)+z)
            }else{
                if (reconstructVisible){
                    return Qt.vector3d( 0.0, 0.0, 200+Math.max(x2,y2)+z2)
                }else{
                    if (poreVisible || throatVisible){
                        return Qt.vector3d( 0.0, 0.0, 200+Math.max(x2,y2)+z2)
                    }else{
                        if (segment_image){
                            return Qt.vector3d( 0.0, 0.0, 200+Math.max(x,y)+z)
                        }else{
                            return Qt.vector3d( 0.0, 0.0, 3.0)
                        }
                    }
                }
            }
        }

//        {
//            if (segmentVisible && (poreVisible || throatVisible)){
//                return Qt.vector3d( 0.0, 0.0, 200+Math.max(x,y)+z)
//            }else if (reconstructVisible && (poreVisible || throatVisible)){
//                return Qt.vector3d( 0.0, 0.0, 200+Math.max(x2,y2)+z2)
//            }else if (segmentVisible){
//                return Qt.vector3d( 0.0, 0.0, 200+Math.max(x,y)+z)
//            }else if (reconstructVisible){
//                return Qt.vector3d( 0.0, 0.0, 200+Math.max(x2,y2)+z2)
//            }else{
//                return Qt.vector3d( 0.0, 0.0, 200+Math.max(x,y)+z)
//            }
//        }

        upVector: Qt.vector3d(0.0, 1.0, 0.0 )
        viewCenter: Qt.vector3d(0.0, 0.0, 0.0)

    }

    SOrbitCameraController { camera: camera }

    components: [
        RenderSettings {
            activeFrameGraph:
                RenderCapture{
                id: renderCapture
                RenderStateSet {
                    renderStates: [
                        CullFace {
                            mode: CullFace.NoCulling
                        },
                        DepthTest { depthFunction: DepthTest.LessOrEqual }
                    ]
                    ForwardRenderer {
                        id: fRenderer
                        camera: camera
                    }
                }
            }
        },
        InputSettings { }
    ]

/*******************************************************************************/
    ThreeSpaceImages{
        id: images
    }

    ThreeReconstructSpace{
        id: images2
    }

    ThreePoreNetwork{
        id: images3
    }

    ThreeThroatNetwork{
        id: images4
    }
}
