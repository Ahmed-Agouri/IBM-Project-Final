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
import 'dart:math' show radians;
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:vector_math/vector_math_64.dart' as vector64;
import 'package:audioplayers/audioplayers.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'package:audioplayers/audioplayers.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';




void _launchURL(String url) async {
  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url));
  } else {
    throw 'Could not launch $url';
  }
}

_launchMailto(String address) async {
  final mailtoLink = Uri.parse('mailto:$address?subject=Interested in Your Services&body=Hello, '
      'I found your business card and am interested in the services you offer. I believe there is potential for a beneficial engagement and would like to discuss how we can work together. Please let me know a convenient time for a conversation.');
  try {
    await launchUrl(mailtoLink);
  } catch (e) {
    // Handle any errors (e.g., if the user's device doesn't support email)
    print('Could not launch $mailtoLink');
  }
}



enum Option {
  Bio,
  Jobs,
  EducationHistory,
  CurrentJob,
}

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

  void playOptionAudio(Option option) {
    final audioPlayer = AudioPlayer();
    String audioFile;

    switch (option) {
      case Option.Bio:
        audioFile = 'john.mp3';
        break;
      case Option.Jobs:
        audioFile = 'pastJobs.mp3';
        break;
      case Option.EducationHistory:
        audioFile = 'education.mp3';
        break;
      case Option.CurrentJob:
        audioFile = 'currentJob.mp3';
        break;
    }

    audioPlayer.play(AssetSource(audioFile));
  }

  Option? selectedOption;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AR View'),
      ),
      body: Stack(
        children: [
          ARView(
            onARViewCreated: onARViewCreated,
            planeDetectionConfig: PlaneDetectionConfig.none,
          ),
          Positioned(
            bottom: 20.0,
            right: 20.0,
            child: FloatingActionButton(
              onPressed: () {
                // Handle screen tap
                showMenu(
                  context: context,
                  position: RelativeRect.fromLTRB(100, 100, 100, 100),
                  items: <PopupMenuEntry<Option>>[
                    PopupMenuItem<Option>(
                      value: Option.Bio,
                      child: Text('Bio'),
                    ),
                    PopupMenuItem<Option>(
                      value: Option.Jobs,
                      child: Text('Jobs'),
                    ),
                    PopupMenuItem<Option>(
                      value: Option.EducationHistory,
                      child: Text('Education History'),
                    ),
                    PopupMenuItem<Option>(
                      value: Option.CurrentJob,
                      child: Text('Current Job'),
                    ),
                  ],
                ).then((Option? value) {
                  if (value != null) {
                    selectedOption = value;
                    playOptionAudio(selectedOption!); // Play audio for selected option
                  }
                });
              },
              child: const Icon(Icons.audiotrack), // Consider using a more descriptive icon
            ),
          ),

        ],
      ),
        bottomNavigationBar: Row(
          children: <Widget>[
            IconButton(
              icon: Icon(
                FontAwesomeIcons.envelope,
                color: Colors.pink,
                size: 75,
              ),
              onPressed: () =>_launchMailto('j0nnymac@uk.ibm.com'),
            ),
            IconButton(
              icon: Icon(
                FontAwesomeIcons.globe,
                color:Colors.blue,
                size: 75,
              ),
              onPressed: () => _launchURL("https://www.ibm.com/uk-en"),
            ),
            IconButton(
              icon: Icon(
                FontAwesomeIcons.instagram,
                color: Colors.purpleAccent,
                size: 75,
              ),
              onPressed: () => _launchURL("https://www.instagram.com/"),
            ),
            IconButton(
              icon: Icon(
                FontAwesomeIcons.linkedin,
                color: Colors.blue,
                size: 60,
              ),
              onPressed: () => _launchURL('https://www.linkedin.com/search/results/all/?fetchDeterministicClustersOnly=true&heroEntityKey=urn%3Ali%3Afsd_profile%3AACoAAAHFoQsB8wRGwfZwZF5k3KN36KwpehIrnhw&keywords=john%20mcnamara&origin=RICH_QUERY_TYPEAHEAD_HISTORY&position=0&searchId=4e356b99-c59d-4385-a2e7-31fbae90bbeb&sid=.O_&spellCorrectionEnabled=true'),
            )
          ],
        )
    );
  }


  void onARViewCreated(ARSessionManager arSessionManager, ARObjectManager arObjectManager, ARAnchorManager arAnchorManager, ARLocationManager arLocationManager) {
    this.arSessionManager = arSessionManager;
    this.arObjectManager = arObjectManager;

    arSessionManager.onInitialize(
      showFeaturePoints: false,
      showPlanes: true ,
      customPlaneTexturePath: "Images/triangle.png",
      showWorldOrigin: true,
      handleTaps: true,

    );
    arObjectManager.onInitialize();

    onLocalObjectAtOriginButtonPressed();
  }

  Future<void> onLocalObjectAtOriginButtonPressed() async {
    // Define the node for your avatar
    var newNode = ARNode(
        type: NodeType.localGLTF2,
        // Use localGLB or localGLTF2 depending on your model format
        uri: "assets/scene.gltf",
        // Path to your model
      scale: vector.Vector3(0.099,0.099, 0.099), // Adjust scale as needed (e.g., 0.5 for half a meter)
      position: vector.Vector3(0.0, -0.2, -0.5),
      rotation: vector.Vector4(10.0, 0.0, 1.0, 0.0), );

    // Add logging before node creation
    print("Creating ARNode with details:");
    print("  - type: ${newNode.type}");
    print("  - uri: ${newNode.uri}");
    print("  - scale: ${newNode.scale}");
    print("  - position: ${newNode.position}");
    print("  - rotation: ${newNode.rotation}");

    // Add the node to the AR scene
    bool? didAddNode = await arObjectManager?.addNode(newNode);
    localObjectNode = didAddNode == true ? newNode : null;
    if (didAddNode == true) {
      print("Added GLB model successfully.");
    } else
      print("Failed to add GLB model.");
  }}