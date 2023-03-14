import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/model/card_model.dart';
import 'main_state.dart';

class MainCubit extends Cubit<MainState> {
  MainCubit() : super(MainState());

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  getCard() async {
    var res = await firestore.collection("card").get();
    List<CardModel> newList = [];
    List newListId = [];
    num balance = 0;
    for (var element in res.docs) {
      newList.add(CardModel.fromJson(element.data()));
      newListId.add(element.id);
      balance += CardModel.fromJson(element.data()).money;
    }
    emit(state.copyWith(
        list: newList, balance: balance, listOfCardId: newListId));
  }

  addCard() async {
    await firestore.collection("card").add(CardModel(
            number: state.newNumber ?? "",
            money: state.newMoney ?? 0,
            image: state.newImage ??
                "https://upload.wikimedia.org/wikipedia/commons/8/89/HD_transparent_picture.png",
            color: state.newColor ?? "",
            expiration: state.newExpire ?? "",
            ownerName: state.newName ?? "",
            cardType: state.newCardType ?? "visa_card")
        .toJson());
    getCard();
  }

  cleanNewFields() {
    emit(state.copyWith(
        nNumber: "Card Number",
        nSelectedCardTypeIndex: 0,
        nSelectedImageIndex: -1,
        nSelectedColorIndex: 0,
        nExpire: "Expiration date",
        nMoney: 0,
        nName: "Owner Name",
        nColor: "0xff8EDFEB",
        nImage:
            "https://upload.wikimedia.org/wikipedia/commons/8/89/HD_transparent_picture.png",
        nCardType: "visa_card"));
  }

  getNewCard(
      {String? name,
      String? number,
      String? expire,
      String? cardType,
      num? money,
      String? color,
      String? image,
      int? colorIndex,
      int? imageIndex,
      int? typeIndex}) {
    emit(state.copyWith(
        nExpire: expire,
        nNumber: number,
        nCardType: cardType,
        nMoney: money,
        nName: name,
        nColor: color,
        nImage: image,
        nSelectedColorIndex: colorIndex,
        nSelectedImageIndex: imageIndex,
        nSelectedCardTypeIndex: typeIndex));
  }

  initializeNewFields(int index) {
    emit(state.copyWith(
      nCardType: state.listOfCards?[index].cardType,
      nImage: state.listOfCards?[index].image,
      nColor: state.listOfCards?[index].color,
      nName: state.listOfCards?[index].ownerName,
      nMoney: state.listOfCards?[index].money,
      nExpire: state.listOfCards?[index].expiration,
      nNumber: state.listOfCards?[index].number,
    ));
  }

  editCard(
      {String? name,
      String? number,
      String? expire,
      String? cardType,
      num? money,
      String? color,
      String? image,
      int? colorIndex,
      int? imageIndex,
      int? typeIndex}) {
    emit(state.copyWith(
        nExpire: expire,
        nNumber: number,
        nCardType: cardType,
        nMoney: money,
        nName: name,
        nColor: color,
        nImage: image,
        nSelectedColorIndex: colorIndex,
        nSelectedImageIndex: imageIndex,
        nSelectedCardTypeIndex: typeIndex));
  }

  finalizeEdit(int index) {
    firestore.collection("card").doc(state.listOfCardId?[index]).update({
      "owner": state.newName,
      "cardType": state.newCardType,
      "color": state.newColor,
      "number": state.newNumber,
      "money": state.newMoney,
      "expiration": state.newExpire,
      "image": state.newImage
    });
    getCard();
  }

  deleteCard(int index) {
    firestore.collection("card").doc(state.listOfCardId?[index]).delete();
    state.totalBalance != 0
        ? state.totalBalance =
            state.totalBalance! - (state.listOfCards?[index].money ?? 0)
        : state.totalBalance = 0;
    state.listOfCards?.removeAt(index);
    state.listOfCardId?.removeAt(index);
    emit(state.copyWith(list: state.listOfCards, balance: state.totalBalance));
  }
}
