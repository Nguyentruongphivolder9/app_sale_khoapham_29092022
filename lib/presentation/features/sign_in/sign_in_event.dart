
/*
  * Create by phat 15-11-2022
  *
  * Event From Sign In Page
  *
 */
import 'package:app_sale_khoapham_29092022/common/bases/base_event.dart';

class SignInEvent extends BaseEvent {
  String email, password;

  SignInEvent({required this.email, required this.password});

  /*
   * Compare instance
   *
   * @return [List<Object?>]
   */
  @override
  List<Object?> get props => [];

}

class SignInSuccessEvent extends BaseEvent {
  @override
  List<Object?> get props => [];

}

class SignInFailEvent extends BaseEvent {
  String message;

  SignInFailEvent({required this.message});
  @override
  List<Object?> get props => [];

}