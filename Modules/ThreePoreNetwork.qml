import Qt3D.Core 2.15
import Qt3D.Render 2.15
import Qt3D.Extras 2.15
import QtQuick 2.15 as QQ

NodeInstantiator {
    id: root

    property QQ.ListModel pModel
    property bool visible: false
    property string color: "#0000ff"
    property real x: 0
    property real y: 0
    property real z: 0
    property real scale: 1
    property vector3d position: Qt.vector3d(0.0, 0.0, 0.0)
    property real rotationAngle: 0.0

    model: pModel

    delegate: Entity{

        PhongMaterial {
            id: material
            diffuse: root.color
            ambient: Qt.rgba(0.55,0.55,0.55,1)
            shininess: 50
        }

        Transform {
            id: transform
            scale: root.scale
            //        rotation: fromAxisAndAngle(root.rotationAxis, root.rotationAngle)
            translation: Qt.vector3d(model.Coordx-(x/2), model.Coordy-(y/2), model.Coordz-(z/2))
        }

        SphereMesh {
            id: mesh
            radius: model.Radi
            rings: 10
            slices: 10
        }
        components: (visible) ? [mesh, material, transform]:[]
    }
}


