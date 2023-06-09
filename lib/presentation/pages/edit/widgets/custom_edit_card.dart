import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../application/main_cubit.dart';
import '../../../../application/main_state.dart';
import '../../../../infrastructure/masked.dart';
import '../../../style/style.dart';

// ignore: must_be_immutable
class CustomEditCard extends StatefulWidget {
  int index;

  CustomEditCard({Key? key, required this.index}) : super(key: key);

  @override
  State<CustomEditCard> createState() => _CustomEditCardState();
}

class _CustomEditCardState extends State<CustomEditCard> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: BlocProvider.of<MainCubit>(context),
      child: BlocBuilder<MainCubit, MainState>(
        builder: (context, state) {
          return Container(
            height: 171,
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
                color: Color(int.parse(
                    state.listOfCards?[widget.index].color ??
                        "0xff8EDFEB")),
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                    image: NetworkImage(state.newImage ??
                        "https://upload.wikimedia.org/wikipedia/commons/8/89/HD_transparent_picture.png"),
                    fit: BoxFit.cover)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.newName ?? "Owner's name",
                            style: Style.textStyleRegular(
                                size: 12, textColor: Style.whiteColor),
                          ),
                          12.verticalSpace,
                          Text(
                            state.listOfCards?[widget.index].number !=
                                null
                                ? maskedCard(state.newNumber.toString())
                                : "Card number",
                            style: Style.textStyleBold(
                                size: 24, textColor: Style.whiteColor),
                          )
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "A Credit Card",
                            style: Style.textStyleRegular(
                                size: 12, textColor: Style.whiteColor),
                          ),
                          12.verticalSpace,
                          Text(
                            state.newExpire ?? "Expiration date",
                            style: Style.textStyleBold(
                                size: 16, textColor: Style.whiteColor),
                          ),
                        ],
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Your Balance",
                            style: Style.textStyleRegular(
                                size: 12,
                                textColor:
                                Style.whiteColor.withOpacity(0.7)),
                          ),
                          Text(
                            state.newMoney.toString(),
                            style: Style.textStyleBold(
                                size: 22, textColor: Style.whiteColor),
                          )
                        ],
                      ),
                      Container(
                        height: 50,
                        width: 80,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage(
                                    "assets/${state.newCardType ??
                                        "visa_card"}.png"),
                                fit: BoxFit.cover)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
