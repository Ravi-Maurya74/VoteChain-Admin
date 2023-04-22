import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:voting_blockchain/helpers/networking.dart';
import 'package:voting_blockchain/widgets/custom_appbar.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:animate_do/animate_do.dart';
import 'package:local_hero/local_hero.dart';

class NewElectionPage extends StatefulWidget {
  const NewElectionPage({super.key});

  @override
  State<NewElectionPage> createState() => _NewElectionPageState();
}

class _NewElectionPageState extends State<NewElectionPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int _currentValue = 2;
  List<String> choices = List<String>.filled(10, "", growable: false);
  String title = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: LocalHeroScope(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeIn,
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CustomAppbar(title: "New Election"),
                    SingleTextField(
                      label: "Title",
                      onChange: (value) {
                        title = value;
                      },
                      vldator: (value) {
                        if (value!.isEmpty) return "This field is required.";
                        return null;
                      },
                    ),
                    SingleInputRow(
                      label: "Choices",
                      child: NumberPicker(
                        selectedTextStyle:
                            Theme.of(context).textTheme.titleLarge,
                        decoration: BoxDecoration(),
                        itemWidth: 50,
                        infiniteLoop: true,
                        axis: Axis.horizontal,
                        minValue: 2,
                        maxValue: 10,
                        value: _currentValue,
                        onChanged: (value) {
                          setState(() {
                            _currentValue = value;
                          });
                        },
                      ),
                    ),
                    ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        if (index <= 1) {
                          return SingleTextField(
                            label: "Choice ${index + 1}",
                            onChange: (p0) {
                              choices[index] = p0;
                            },
                            vldator: (p0) {
                              if (p0!.isEmpty) return "This field is required.";
                              return null;
                            },
                            minLines: 1,
                          );
                        } else {
                          return ZoomIn(
                            duration: const Duration(seconds: 1),
                            child: SingleTextField(
                              label: "Choice ${index + 1}",
                              onChange: (p0) {
                                choices[index] = p0;
                              },
                              vldator: (p0) {
                                if (p0!.isEmpty)
                                  return "This field is required.";
                                return null;
                              },
                              minLines: 1,
                            ),
                          );
                        }
                      },
                      itemCount: _currentValue,
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    LocalHero(
                      tag: "hero-button",
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            List<String> choice_list =
                                choices.sublist(0, _currentValue);
                            CoolAlert.show(
                                context: context,
                                type: CoolAlertType.loading,
                                barrierDismissible: false);
                            var result = await NetworkHelper().postData(
                                url: "createNewElection/",
                                jsonMap: {
                                  "title": title,
                                  "number_of_choices": _currentValue,
                                  "choices": choice_list
                                });
                            Navigator.pop(context);
                            if (result.statusCode != 200) return;
                            await CoolAlert.show(
                                context: context,
                                type: CoolAlertType.success,
                                barrierDismissible: false);
                            Navigator.pop(context);
                          }
                          return;
                        },
                        child: Text(
                          "Create",
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(fontFamily: "Alkatra"),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SingleTextField extends StatelessWidget {
  const SingleTextField({
    required this.label,
    required this.onChange,
    required this.vldator,
    this.minLines = 8,
    Key? key,
  }) : super(key: key);
  final String label;
  final void Function(String)? onChange;
  final String? Function(String?)? vldator;
  final int minLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              const SizedBox(
                height: 8,
              ),
              SizedBox(width: 130, child: Text(label)),
            ],
          ),
          const SizedBox(
            width: 20,
          ),
          Expanded(
            child: DecoratedContainer(
              child: TextFormField(
                onChanged: onChange,
                minLines: minLines,
                maxLines: null,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  // hintText: 'Leave blank for same',
                  hintStyle: Theme.of(context).textTheme.bodySmall,
                ),
                validator: vldator,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DecoratedContainer extends StatelessWidget {
  const DecoratedContainer({required this.child, super.key});
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 15, right: 15, bottom: 0),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(37, 42, 52, 1),
        borderRadius: BorderRadius.circular(17),
      ),
      child: child,
    );
  }
}

class SingleInputRow extends StatelessWidget {
  const SingleInputRow({
    required this.label,
    required this.child,
    Key? key,
  }) : super(key: key);
  final String label;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              const SizedBox(
                height: 8,
              ),
              SizedBox(width: 130, child: Text(label)),
            ],
          ),
          const SizedBox(
            width: 20,
          ),
          Expanded(
            child: child!,
          ),
        ],
      ),
    );
  }
}
