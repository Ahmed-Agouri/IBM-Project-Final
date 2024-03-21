import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'dart:math';
import 'package:path_provider/path_provider.dart';

class LocalAndWebObjectsWidget extends StatefulWidget {
  @override
  _LocalAndWebObjectsWidgetState createState() => _LocalAndWebObjectsWidgetState();
}

class _LocalAndWebObjectsWidgetState extends State<LocalAndWebObjectsWidget> {
  ARSessionManager? arSessionManager;
  ARObjectManager? arObjectManager;
  ARNode? localObjectNode;

  @override
  void dispose() {
    arSessionManager?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local & Web Objects'),
      ),
      body: ARView(
        onARViewCreated: onARViewCreated,
        planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
      ),
    );
  }

  void onARViewCreated(ARSessionManager arSessionManager, ARObjectManager arObjectManager, ARAnchorManager arAnchorManager, ARLocationManager arLocationManager) {
    this.arSessionManager = arSessionManager;
    this.arObjectManager = arObjectManager;

    arSessionManager.onInitialize(
      showFeaturePoints: false,
      showPlanes: true,
      customPlaneTexturePath: "Images/triangle.png",
      showWorldOrigin: true,
      handleTaps: false,
    );
    arObjectManager.onInitialize();

    // Call the method to add your avatar as soon as the AR session is initialized
    onLocalObjectAtOriginButtonPressed();
  }

  Future<void> onLocalObjectAtOriginButtonPressed() async {
    // Define the node for your avatar
    var newNode = ARNode(
        type: NodeType.fileSystemAppFolderGLTF2,// Use localGLB or localGLTF2 depending on your model format
        uri: "assets/BlenderAvatar.gltf", // Path to your model
        scale: vector.Vector3(1.0, 1.0, 1.0), // Adjust scale as needed
        position: vector.Vector3(0.0, 0.0, -2.0), // Adjust position as needed
        rotation: vector.Vector4(0.0, 0.0, 0.0, 1.0));

    // Add the node to the AR scene
    bool? didAddNode = await arObjectManager?.addNode(newNode);
    localObjectNode = didAddNode == true ? newNode : null;
    if (didAddNode == true) {
      print("Added GLB model successfully.");
    } else {
      print("Failed to add GLB model.");
    }
  }
}
