import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noteapp/apis/login_api.dart';
import 'package:noteapp/apis/notes_api.dart';
import 'package:noteapp/bloc/actions.dart';
import 'package:noteapp/bloc/app_bloc.dart';
import 'package:noteapp/bloc/app_state.dart';
import 'package:noteapp/dialogs/generic_dialog.dart';
import 'package:noteapp/dialogs/loading_screen.dart';
import 'package:noteapp/models.dart';
import 'package:noteapp/strings.dart';
import 'package:noteapp/views/iterable_list_view.dart';
import 'package:noteapp/views/login_view.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Note App",
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget
{
  HomePage({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context)
  {
    return  BlocProvider(
      create: (context) => AppBloc(
        loginApi: LoginApi(), 
        notesApi: NotesApi()),
        child: Scaffold(
          appBar: AppBar(
            title: const Text(homePage),
          ),
          body: BlocConsumer<AppBloc,AppState>(
            listener: (context,appState)
            {
              if (appState.isLoading)
              {
                LoadingScreen.instance().show(context: context, 
                text: pleaseWait);
              }
              else
              {
                LoadingScreen.instance().hide();
              }

              final loginError = appState.loginError;

              if (loginError != null)
              {
                showGenericDialog<bool>(
                  context: context, 
                  title: loginErrorDilogTitle, 
                  content: loginErrorDialogContent, 
                  optionsBuilder: () => {ok:true});
              }

              if (appState.isLoading == false && appState.loginError == null
              && appState.loginHandle == const LoginHandle.fooBar() &&
              appState.fetchedNotes == null)
              {
                context.read<AppBloc>().add(const LoadNotesAction());
              }


            },
            builder: (context, appState) {
              final notes = appState.fetchedNotes;

              if (notes==null)
              {
                return LoginView(
                  onLoginTapped: (email,password) {
                    context.read<AppBloc>().add(
                      LoginAction(email: email,
                       password: password)
                    );
                  });
              }
              else
              {
                return notes.toListView();
              }
            },
          ),
        ),
        );
  }
}
