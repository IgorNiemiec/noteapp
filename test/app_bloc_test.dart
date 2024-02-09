

import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_test/flutter_test.dart';
import 'package:noteapp/apis/login_api.dart';
import 'package:noteapp/apis/notes_api.dart';
import 'package:noteapp/bloc/actions.dart';
import 'package:noteapp/bloc/app_bloc.dart';
import 'package:noteapp/bloc/app_state.dart';
import 'package:noteapp/models.dart';

const Iterable<Note> mockNotes = 
[
  Note(title: "Note 1"),
  Note(title: "Note 2"),
  Note(title: "Note 3"),
];


const acceptedLoginHande = LoginHandle(token: "ABC");

@immutable
class DummyNotesApi implements NotesApiProtocol
{
  final LoginHandle acceptedLoginHandle;
  final Iterable<Note>? notesToReturnForAcceptedLoginHandle;

 const DummyNotesApi({
    required this.acceptedLoginHandle,
    required this.notesToReturnForAcceptedLoginHandle, 
  });
  
  const DummyNotesApi.empty() :
  acceptedLoginHandle = const LoginHandle.fooBar(),
  notesToReturnForAcceptedLoginHandle = null;
  
  @override
  Future<Iterable<Note>?> getNotes({required LoginHandle loginHandle}) async {
   
    if (loginHandle == acceptedLoginHandle)
    {
      return notesToReturnForAcceptedLoginHandle;
    }
    else
    {
      return null;
    }

  }

  

}

@immutable
class DummyLoginApi implements LoginApiProtocol
{
  final String acceptedEmail;
  final String acceptedPassword;
  final LoginHandle handleToReturn;

  const DummyLoginApi({
    required this.acceptedEmail,
    required this.acceptedPassword,
    required this.handleToReturn,
  });

  const DummyLoginApi.empty() : 
  acceptedEmail = '',
  acceptedPassword = '',
  handleToReturn = const LoginHandle.fooBar();

  
  @override
  Future<LoginHandle?> login({required String email, required String password}) async{
    
    if (email == acceptedEmail && password == acceptedPassword)
    {
      return handleToReturn;
    }
    else
    {
      return null;
    }
    
  }

  
}


void main()
{
  blocTest<AppBloc,AppState>("Initial state of the bloc should be AppState.empty()",
   build: () => AppBloc(
    loginApi: const DummyLoginApi.empty(), 
    notesApi: const DummyNotesApi.empty(),
    acceptedLoginHandle: const LoginHandle(token: "ABC")),
    
    verify: (appState) => expect(appState.state,const AppState.empty()),
  
    );


    blocTest<AppBloc,AppState>("Can we log in with correct credentials?",
   build: () => AppBloc(
    loginApi: const DummyLoginApi(
      acceptedEmail: "bar@baz.com",
      acceptedPassword: "foo",
      handleToReturn: LoginHandle(token: "ABC")), 
      
    notesApi: const DummyNotesApi.empty(),
    acceptedLoginHandle: const LoginHandle(token: "ABC")),
    
    
    act: (appBloc) => appBloc.add(
      const LoginAction(
        email: "bar@baz.com", 
        password: "foo"),
    ),

    expect: () => 
    [
      const AppState(
        isLoading: true,
        loginError: null,
        loginHandle: null,
        fetchedNotes: null,
      ),
       
      const AppState(
        isLoading: false, 
        loginError: null, 
        loginHandle: LoginHandle(token: "ABC"), 
        fetchedNotes: null)
    ] 
    );


     blocTest<AppBloc,AppState>("We should not be able to log in with invalid credentials",
   build: () => AppBloc(
    loginApi: const DummyLoginApi(
      acceptedEmail: "foo@bar.com",
      acceptedPassword: "baz",
      handleToReturn: LoginHandle(token: "ABC")), 
      
    notesApi: const DummyNotesApi.empty(),
    acceptedLoginHandle: LoginHandle(token: "ABC")),
    
    act: (appBloc) => appBloc.add(
      const LoginAction(
        email: "bar@baz.com", 
        password: "foo"),
    ),

    expect: () => 
    [
      const AppState(
        isLoading: true,
        loginError: null,
        loginHandle: null,
        fetchedNotes: null,
      ),
       
      const AppState(
        isLoading: false, 
        loginError: LoginErrors.invalidHandle, 
        loginHandle: null, 
        fetchedNotes: null)
    ] 
    );


    blocTest<AppBloc,AppState>("Load notes with a valid login Handle",
     build: () => AppBloc(
      loginApi: const DummyLoginApi(
        acceptedEmail: "foo@bar.com", 
        acceptedPassword: "baz", 
        handleToReturn: acceptedLoginHande), 
      notesApi: const DummyNotesApi(
        acceptedLoginHandle: acceptedLoginHande, 
        notesToReturnForAcceptedLoginHandle: mockNotes), 
      acceptedLoginHandle: acceptedLoginHande),

      act: (appBloc)
      {
        appBloc.add( const LoginAction(
          email: "foo@bar.com", 
          password: "baz"));

        appBloc.add(const LoadNotesAction());
      },
      
      expect: () 
      {
         const AppState(
          isLoading: true, 
          loginError: null, 
          loginHandle: null, 
          fetchedNotes: null);

          const AppState(
          isLoading: false, 
          loginError: null, 
          loginHandle: acceptedLoginHande, 
          fetchedNotes: null);

          const AppState(
          isLoading: true, 
          loginError: null, 
          loginHandle: acceptedLoginHande, 
          fetchedNotes: null);

          const AppState(
          isLoading: false, 
          loginError: null, 
          loginHandle: acceptedLoginHande, 
          fetchedNotes: mockNotes);

      }  
   );
}