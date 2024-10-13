import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:animated_list_plus/transitions.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:schulapp/code_behind/school_note.dart';

class EditNoteScreen extends StatefulWidget {
  final SchoolNote schoolNote;

  const EditNoteScreen({
    super.key,
    required this.schoolNote,
  });

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  final TextEditingController _headingTextController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Note"),
      ),
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _headingTextController,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: "Titel",
            ),
            style: Theme.of(context).textTheme.headlineLarge,
          ),
        ),
        Expanded(
          child: ImplicitlyAnimatedList<SchoolNotePart>(
            items: widget.schoolNote.parts,
            itemBuilder: (context, animation, item, index) {
              return SizeFadeTransition(
                sizeFraction: 0.7,
                animation: animation,
                key: Key(item.toString()),
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(
                      seconds: 1,
                    ),
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: item.render(),
                  ),
                ),
              );
            },
            areItemsTheSame: (oldItem, newItem) =>
                oldItem.value == newItem.value,
          ),
        ),
        Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _onAddImagePressed,
                icon: const Icon(
                  Icons.add_photo_alternate_outlined,
                ),
              ),
              IconButton(
                onPressed: _onAddTextPressed,
                icon: const Icon(
                  Icons.add_box_outlined,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _onAddImagePressed() async {
    final ImagePicker picker = ImagePicker();

    final XFile? imageFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (imageFile == null) return;

    // final ByteData data = await imageFile
    //     .readAsBytes()
    //     .then((value) => ByteData.sublistView(value));

    widget.schoolNote.parts.add(
      SchoolNotePartImage(
        value: imageFile.path,
      ),
    );
    setState(() {});
  }

  void _onAddTextPressed() {
    widget.schoolNote.parts.add(
      SchoolNotePartText(),
    );
    setState(() {});
  }
}
