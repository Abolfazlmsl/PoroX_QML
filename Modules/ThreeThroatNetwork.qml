import Qt3D.Core 2.15
import Qt3D.Render 2.15
import Qt3D.Extras 2.15
import QtQuick 2.15 as QQ

NodeInstantiator {
    id: root

    property QQ.ListModel tModel
    property bool visible: false
    property string color: "#ff0000"
    property real x: 0
    property real y: 0
    property real z: 0
    property real scale: 1
    property vector3d position: Qt.vector3d(0.0, 0.0, 0.0)
    property real rotationAngle: 0.0
    property vector3d rotationAxis: Qt.vector3d(50, 50, -500)

    model: tModel

    delegate: Entity{
        PhongMaterial {
            id: material
            diffuse: root.color
            ambient: Qt.rgba(0.55,0.55,0.55,1)
            shininess: 50
        }

        Transform {
            id: transform
//            scale: root.scale
            rotation: fromAxisAndAngle(Qt.vector3d(model.Rotatex, model.Rotatey, model.Rotatez), model.Angle)
            translation: Qt.vector3d(model.Centerx-(x/2), model.Centery-(y/2), model.Centerz-(z/2))
        }

        CylinderMesh {
            id: mesh
            radius: model.Radi * root.scale
            length: model.Length
            rings: 10
            slices: 10
        }
        components: (visible)? [mesh, material, transform]:[]
    }
}


