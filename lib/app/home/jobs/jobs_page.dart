import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_tracker_flutter_course/app/home/jobs/add_job_page.dart';
import 'package:time_tracker_flutter_course/app/home/models/job.dart';
import 'package:time_tracker_flutter_course/common_widgets/show_alert_dialog.dart';
import 'package:time_tracker_flutter_course/services/auth.dart';
import 'package:time_tracker_flutter_course/services/database.dart';

class JobsPage extends StatelessWidget {
  Future<void> _signOut(BuildContext context) async {
    final auth = Provider.of<AuthBase>(context, listen: false);
    await auth.signOut();
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final didRequestSignOut = await showAlertDialog(
      context,
      title: 'Logout',
      content: 'Are you sure that you want to logout?',
      defaultActionText: 'Logout',
      cancelActionText: 'Cancel',
    );
    if (didRequestSignOut) {
      await _signOut(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Jobs',
        ),
        actions: [
          TextButton(
            onPressed: () => _confirmSignOut(context),
            child: Text(
              'Logout',
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => AddJobPage.show(context),
        child: Icon(Icons.add),
      ),
      body: buildContents(context),
    );
  }

  Widget buildContents(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    return StreamBuilder<List<Job>>(
      stream: database.jobsStream(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final jobs = snapshot.data;
          final children = jobs.map((job) => Text(job.name)).toList();
          return ListView(
            children: children,
          );
        }
        if (snapshot.hasError) {
          return Center(child: Text('Some error occurred'));
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
