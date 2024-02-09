import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noteapp/apis/login_api.dart';
import 'package:noteapp/apis/notes_api.dart';
import 'package:noteapp/bloc/actions.dart';
import 'package:noteapp/bloc/app_state.dart';
import 'package:noteapp/models.dart';

class AppBloc extends Bloc<AppAction,AppState>
{

  final LoginApiProtocol loginApi;
  final NotesApiProtocol notesApi;
  final LoginHandle acceptedLoginHandle;

  AppBloc({
    required this.loginApi, 
    required this.notesApi,
    required this.acceptedLoginHandle}) : super(const AppState.empty())
  {
    on<LoginAction>((event,emit) async
    {
      emit(const AppState(isLoading: true, loginError: null, loginHandle: null, fetchedNotes: null));

      final logginHande = await loginApi.login(
        email: event.email,
        password: event.password);


      emit(AppState(
      isLoading: false,
      loginError: logginHande == null ? LoginErrors.invalidHandle : null,
      loginHandle: logginHande, 
      fetchedNotes: null
      ));

        

    
    });

    on<LoadNotesAction>(((event, emit) async {
      
      emit(AppState(
        isLoading: true, 
        loginError: null, 
        loginHandle: state.loginHandle, 
        fetchedNotes: null));

        final logginHandle = state.loginHandle;

        if (logginHandle != acceptedLoginHandle)
        {
          emit(AppState(
            isLoading: false, 
            loginError: LoginErrors.invalidHandle, 
            loginHandle: logginHandle, 
            fetchedNotes: null));
          return;
        }
        
        final notes = await NotesApi().getNotes(loginHandle: logginHandle!);

        emit(AppState(
          isLoading: false, 
          loginError: null, 
          loginHandle: logginHandle, 
          fetchedNotes: notes));

    }));
  }


}