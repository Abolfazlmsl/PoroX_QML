import Qt3D.Core 2.0
import Qt3D.Render 2.0
import Qt3D.Extras 2.0

Entity {
    id: root

    property vector3d position: Qt.vector3d(0, 0, 0)
    property real scale: 1.0
    property real rotationAngle: 90.0
    property vector3d rotationAxis: Qt.vector3d(2, 0, 0)
//    property alias source: mesh.source
    property Material material

    components: [ transform, mesh, root.material ]

    Transform {
        id: transform
        scale: root.scale
        rotation: fromAxisAndAngle(root.rotationAxis, root.rotationAngle)
        translation: root.position
    }

    PlaneMesh {
//        width: 915/925
//        height: 925/925
        id: mesh
    }
}
