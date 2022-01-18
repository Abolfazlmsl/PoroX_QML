import Qt3D.Core 2.15
import Qt3D.Render 2.15
import Qt3D.Extras 2.15
import QtQuick 2.15 as QQ

Entity {
    id: root

    property bool visible: false
    property real x: 0
    property real y: 0
    property real z: 0
    property real scale: 1
    property Texture2D mapTexture: texture
    property vector3d position: Qt.vector3d(-x/2-20, -y/2-20, -z/2-15)
    property real rotationAngle: -90.0
    property vector3d rotationAxis: Qt.vector3d(1.0, 0.0, 0.0)

    property string source1: ""

//    PhongMaterial {
//        id: material
//        //        diffuse: "red"
//        ambient: Qt.rgba(0.2,0.2,0.2,1)
//        specular: Qt.rgba(0.2,0.2,0.2,1)
//        shininess: 50
//    }

    MetalRoughMaterial {
        id: material
//        baseColor: Qt.rgba( 0.05, 0.05, 0.05, 1.0 )
        metalness: 0
        roughness: 0
    }

    Transform {
        id: transform
        scale: root.scale
        //        rotation: fromAxisAndAngle(root.rotationAxis, root.rotationAngle)
        translation: root.position
    }

    Mesh {
        id: mesh
        source: source1
    }

    PlaneMesh{
        id: planemesh
    }

    Transform {
        id: transform2
        scale: root.scale
        rotation: fromAxisAndAngle(root.rotationAxis, root.rotationAngle)
    }

    Texture2D{
        id: texture
        magnificationFilter: Texture.Linear
        minificationFilter: Texture.Linear
        wrapMode {
            x: WrapMode.Repeat
            y: WrapMode.Repeat
        }
        maximumAnisotropy: 16.0
        TextureImage{
            source: (visible)?source1:"../Images/Resultpanel.png"
        }

    }

    DiffuseMapMaterial {
        id: material2
        diffuse: mapTexture
        ambient: Qt.rgba(1,1,1,1)
        shininess: 50
    }

    components: (visible)? (inputdata === "3D Gray" || inputdata === "3D Binary" || segment_image)?
                               [mesh, material, transform]:[planemesh, material2, transform2]:[]
}
