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
    property vector3d position: Qt.vector3d(-x/2-20, -y/2-20, -z/2-15)

    property string source1: ""

//    PhongMaterial {
//        id: material
//        //        diffuse: "red"
//        ambient: Qt.rgba(0.2,0.2,0.2,1)
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

    components: (visible)? [mesh, material, transform]:[]
}
