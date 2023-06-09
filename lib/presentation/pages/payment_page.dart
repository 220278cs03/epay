import 'package:epay/presentation/components/custom_add_button.dart';
import 'package:epay/presentation/components/custom_card.dart';
import 'package:epay/presentation/components/custom_textform_field.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:motion_toast/resources/arrays.dart';

import '../../application/main_cubit.dart';
import '../../application/main_state.dart';
import '../../infrastructure/unfocused_tap.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({Key? key}) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late MaskedTextController cardController;
  late TextEditingController moneyController;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String? fcmToken = "";

  @override
  void initState() {
    getToken();
    cardController = MaskedTextController(mask: '0000 0000 0000 0000');
    moneyController = TextEditingController();
    context.read<MainCubit>().findFavorite();
    super.initState();
  }

  @override
  void dispose() {
    cardController.dispose();
    moneyController.dispose();
    super.dispose();
  }

  Future<void> getToken() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      sound: true,
    );
    fcmToken = await FirebaseMessaging.instance.getToken();
    FirebaseMessaging.onMessage.listen((event) {
      MotionToast.success(
        position: MotionToastPosition.top,
        title: Text(event.data["body"] ?? "body"),
        description: Text(event.data["title"] ?? "title"),
      ).show(context);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((event) {});
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<MainCubit>(),
      child: OnUnFocusTap(
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.only(left: 30, right: 30, top: 40),
            child: BlocBuilder<MainCubit, MainState>(
              builder: (context, state) {
                return Form(
                  key: formKey,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                            child: Text("Make a payment",
                                style:Theme.of(context).textTheme.displayMedium)),
                        24.verticalSpace,
                        CustomTextFormField(
                            controller: cardController,
                            keyboardType: TextInputType.number,
                            onChanged: (s) {},
                            validator: (s) {
                              if (s?.isEmpty ?? true) {
                                return "*Enter the card number";
                              }
                              return null;
                            },
                            hintText: "Card number"),
                        12.verticalSpace,
                        CustomTextFormField(
                            controller: moneyController,
                            keyboardType: TextInputType.number,
                            onChanged: (s) {},
                            validator: (s) {
                              if (s?.isEmpty ?? true) {
                                return "*Enter the amount of money";
                              }
                              return null;

                            },
                            hintText: "Amount of money"),
                        12.verticalSpace,
                        (state.listOfCards?.isNotEmpty ?? false) ||
                                state.favIndex != null
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                   Text("You are paying from", style: Theme.of(context).textTheme.headline3,),
                                  8.verticalSpace,
                                  CustomCard(
                                    expiration: state
                                        .listOfCards![state.favIndex ?? 0]
                                        .expiration,
                                    money: state
                                        .listOfCards![state.favIndex ?? 0]
                                        .money,
                                    number: state
                                        .listOfCards![state.favIndex ?? 0]
                                        .number,
                                    name: state
                                        .listOfCards![state.favIndex ?? 0]
                                        .ownerName,
                                    color: state
                                        .listOfCards![state.favIndex ?? 0]
                                        .color,
                                    image: state
                                            .listOfCards?[state.favIndex ?? 0]
                                            .image ??
                                        "https://upload.wikimedia.org/wikipedia/commons/8/89/HD_transparent_picture.png",
                                    cardType: state
                                        .listOfCards![state.favIndex ?? 0]
                                        .cardType,
                                  ),
                                ],
                              )
                            : const Center(
                                child: Text("You do not have a card")),
                        24.verticalSpace,
                        CustomAddButton(
                          onTap: () {
                            if (state.listOfCards?.isEmpty ?? true) {
                              MotionToast.error(
                                      position: MotionToastPosition.top,
                                      title:
                                          const Text("You do not have a card"),
                                      description:
                                          const Text("Please add a new card"))
                                  .show(context);
                            } else if (int.parse(moneyController.text) > state.listOfCards![state.favIndex ?? 0].money) {

                              MotionToast.error(
                                  position: MotionToastPosition.top,
                                  title:  Text("Not Enough Balance"),
                                  description:  Text("Please choose another card")
                              ).show(context);
                            }
                            else if(formKey.currentState?.validate() ??
                                false){
                              context
                                  .read<MainCubit>()
                                  .sendNotification(fcmToken, int.parse(moneyController.text));
                              cardController.clear();
                              moneyController.clear();
                            }
                          },
                          title: "Pay",
                          isValid: formKey.currentState?.validate() ??
                              false,
                        )
                      ]),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
