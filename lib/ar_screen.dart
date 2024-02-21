import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector64;
import 'package:audioplayers/audioplayers.dart';

class ArScreen extends StatefulWidget {
  const ArScreen({super.key});

  @override
  State<ArScreen> createState() => _ArScreenState();
}

class _ArScreenState extends State<ArScreen>
{
  bool isClicked = false;
  bool isAvatarClicked = false;
  ArCoreController? coreController;
  augmentedRealityViewCreated(ArCoreController controller)
  {
    coreController = controller;

    displayCube(coreController!);
    displaySphere(coreController!);
    displayAvatar(coreController!);
  }

  displayCube(ArCoreController controller)
  {
    final materials = ArCoreMaterial(
      color: isClicked ? Colors.red : Colors.indigo,
      metallic: 2,
    );

    final cube = ArCoreCube(
        size: vector64.Vector3(0.5,0.5,0.5),
        materials: [materials],
    );

    final node = ArCoreNode(
      shape: cube,
      position: vector64.Vector3(-0.5,0.5,-3.5),
      name: 'cube',
    );


    coreController!.addArCoreNode(node);
  }

  displaySphere(ArCoreController controller)
  {
    final materials = ArCoreMaterial(
      color: isAvatarClicked ? Colors.red : Colors.indigo,
      metallic: 2,
    );


    final sphere = ArCoreSphere(
      radius: 0.2,
      materials: [materials],
    );

    final node = ArCoreNode(
      shape: sphere,
      position: vector64.Vector3(-0.5,0.5,-1.0),
    );

    coreController!.addArCoreNode(node);
  }

  displayAvatar(ArCoreController controller)
  {
    final materials = ArCoreMaterial(
      color: isAvatarClicked ? Colors.red : Colors.indigo,
      metallic: 2,
    );


    final avatar = ArCoreReferenceNode(
      name: "Astronaut",
      object3DFileName: 'avatars/Astronaut.glb',
      position: vector64.Vector3(-0.5,0.5,-2.0),
      scale: vector64.Vector3(0.2, 0.2, 0.2),
    );

    coreController!.addArCoreNode(avatar);
  }

  void outputAudio()
  {
    final audioPlayer = AudioPlayer();
    audioPlayer.play(AssetSource('john.mp3'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "AR Screen"
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          ArCoreView(
            onArCoreViewCreated: augmentedRealityViewCreated,
            enableTapRecognizer: true,
          ),
          GestureDetector(
            // onTap: () {
            //   setState(() {
            //     isClicked = !isClicked; // Toggle the click state
            //     augmentedRealityViewCreated(coreController!);
            //   });
            // },
            onDoubleTap: (){
              setState(() {
                isAvatarClicked = !isAvatarClicked;
                if(isAvatarClicked == true)
                {
                  outputAudio();
                }
                augmentedRealityViewCreated(coreController!);

              });
            },
            behavior: HitTestBehavior.opaque,
          ),
        ],
      ),
      bottomNavigationBar: const Row(
        children: <Widget>[
          ElevatedButton(
            onPressed: null,
            child: Text('Hello'),
          ),
          ElevatedButton(
            onPressed: null,
            child: Text('Hi'),
          ),
        ],
      )
    );
  }
}
