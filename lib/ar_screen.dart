import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:vector_math/vector_math_64.dart' as vector64;
import 'package:audioplayers/audioplayers.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum Option {
  Bio,
  Jobs,
  EducationHistory,
  CurrentJob,
}

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

    //displayCube(coreController!);
    //displaySphere(coreController!);
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
    final avatar = ArCoreReferenceNode(
      name: "Astronaut",
      object3DFileName: 'avatars/Astronaut.glb',
      position: vector64.Vector3(-0.5,0.5,-2.0),
      scale: vector64.Vector3(5, 5, 5),
    );

    print("Avatar adding...");
    coreController!.addArCoreNode(avatar);
    print("Avatar added");
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

  void JohnIntoAudio()
  {
    final audioPlayer = AudioPlayer();
    audioPlayer.play(AssetSource('john.mp3'));
  }

  _launchURL(String url) async {
    final url1 = Uri.parse(url);
    launchUrl(url1);
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

  Option? selectedOption;

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

          ModelViewer(
            src: 'avatars/Astro&Card.glb',
            autoRotate: false,
            interactionPrompt: InteractionPrompt.none,
          ),
          GestureDetector(
            onTap: (){
              setState(() {
                isAvatarClicked = !isAvatarClicked;
                if(isAvatarClicked == true)
                {
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
                    }
                  });
                }
                augmentedRealityViewCreated(coreController!);
              });
            },
            onDoubleTap: (){
              setState(() {
                isAvatarClicked = !isAvatarClicked;
                if(isAvatarClicked == true && selectedOption != null)
                {
                  playOptionAudio(selectedOption!);
                }
                augmentedRealityViewCreated(coreController!);
              });
            },
            behavior: HitTestBehavior.opaque,
          ),
        ],
      ),
      bottomNavigationBar: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(
          FontAwesomeIcons.envelope,
        color: Colors.pink,
        size: 60,
      ),
            onPressed: () =>_launchMailto('j0nnymac@uk.ibm.com'),
          ),
          IconButton(
            icon: Icon(
              FontAwesomeIcons.globe,
                  color:Colors.blue,
              size: 60,
          ),
            onPressed: () => _launchURL("https://www.ibm.com/uk-en"),
          ),
          IconButton(
            icon: Icon(
          FontAwesomeIcons.instagram,
        color: Colors.purpleAccent,
        size: 60,
      ),
            onPressed: () => _launchURL("https://www.instagram.com/"),
          ),
          IconButton(
            icon: Icon(
          FontAwesomeIcons.facebook,
              color: Colors.blue,
              size: 60,
           ),
            onPressed: () => _launchURL("https://en-gb.facebook.com/"),
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
}
