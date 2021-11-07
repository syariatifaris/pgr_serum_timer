import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimerPage extends StatefulWidget {
  final String title;

  TimerPage({Key? key, required this.title}) : super(key: key);

  @override
  TimerPageState createState() => TimerPageState();
}

class TimerPageState extends State<TimerPage> {
  static const String SP_LAST_SERUM = "SP_LAST_SERUM";
  static const String SP_LAST_SAVED_DATE = "SP_LAST_SAVED_DATE";

  static const int SERUM_REPL_MINUTES_DURATION = 6;
  static const int FULL_SERUM = 160;

  static const String REPLENISHED_TIME_MSG_FORMAT = "Serum Full(160) at ";
  static const String REPLENISHED_MSG_FULL = "Fully Replenished (160) Ready to Go!";

  final _serumInputCtrl = TextEditingController();
  int _serumCount = 0;
  String _replenishiedMsg = REPLENISHED_MSG_FULL;

  SharedPreferences? preferences;

  void store(){
    String currSerum = _serumInputCtrl.text;
    int iSerum = 0;
    try{
      try{
        iSerum = int.parse(currSerum);
      }on Exception catch(e){
        throw Exception("wrong input parameter: "+e.toString());
      }
      this.preferences?.setInt(SP_LAST_SERUM, iSerum);
      //set date time
      DateTime now = DateTime.now();
      this.preferences?.setString(SP_LAST_SAVED_DATE, now.toString());
      setState(() {
        _serumCount = this.preferences?.getInt(SP_LAST_SERUM) ?? 0;
      });
      updateUI();
    }on Exception catch(e){
      print("unable to store the last serum preferences data: "+e.toString());
    }
  }

  Future<void> initializePreferences() async{
    try{
      this.preferences = await SharedPreferences.getInstance();
    }on Exception catch(e){
      print("error while obtaining shared preferences: "+ e.toString());
    }
  }

  int getSerumProgress(){
    var spLastSerum = this.preferences?.getInt(SP_LAST_SERUM) ?? 0;
    print("last serum count = $spLastSerum");
    print("last serum saved date time = ${this.preferences?.getString(SP_LAST_SAVED_DATE)}");
    var lssStrDateTime = this.preferences?.getString(SP_LAST_SAVED_DATE) ?? DateTime.now().toString();
    var lssDateTime = DateTime.parse(lssStrDateTime);
    var minutesDiff = DateTime.now().difference(lssDateTime).inMinutes;
    print("diff in minutes start from last save is: "+minutesDiff.toString());
    
    var serumProgress = (minutesDiff ~/ SERUM_REPL_MINUTES_DURATION);
    return spLastSerum + serumProgress > FULL_SERUM ? FULL_SERUM : spLastSerum + serumProgress;
  }

  String getReplenishMessage(){
    var spLastSerum = this.preferences?.getInt(SP_LAST_SERUM) ?? 0;
    
    var lssStrDateTime = this.preferences?.getString(SP_LAST_SAVED_DATE) ?? DateTime.now().toString();
    var lssDateTime = DateTime.parse(lssStrDateTime);

    var diffToFull = FULL_SERUM - spLastSerum;
    var fullMinutestRequired = diffToFull * SERUM_REPL_MINUTES_DURATION;

    var fullyReplenishedTime = lssDateTime.add(Duration(minutes: fullMinutestRequired));
    return REPLENISHED_TIME_MSG_FORMAT + "${addZero(fullyReplenishedTime.day)}/${addZero(fullyReplenishedTime.month)}/${fullyReplenishedTime.year}" 
      + ",${addZero(fullyReplenishedTime.hour)}:${addZero(fullyReplenishedTime.minute)}";
  }

  @override
  void initState(){
    super.initState();
    initializePreferences().whenComplete((){
      print("shared preferences has been initialized");
      updateUI();
    });
  }

  void updateUI(){
    setState(() {
      _serumCount = getSerumProgress();
      print("current serum progress: "+ _serumCount.toString());

      if(_serumCount < FULL_SERUM){
        _replenishiedMsg = getReplenishMessage();
      }else{
        _replenishiedMsg = REPLENISHED_MSG_FULL;
      }
    });
  }

  String addZero(int number){
    return number < 10? "0$number" : "$number";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 70.0, bottom: 0, left: 100.0, right: 100.0),
              decoration: BoxDecoration(
                image: new DecorationImage(
                  image: new AssetImage('images/img_bianca_pgr.jpg'),
                  fit: BoxFit.cover,
                ),
                color: Colors.black38, 
                shape: BoxShape.circle
              ),
              width: 200,
              height: 200,
              child: Center(
                child: Container(
                  margin: EdgeInsets.only(top: 20),
                  child: Text(
                    '$_serumCount',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black
                    ),
                  )
                ),
              ),
            ),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Container(
                      width: 100,
                      height: 37.5,
                      margin: EdgeInsets.only(right: 2.0),
                      child: TextField(
                        style: TextStyle(
                          fontSize: 14,
                        ),
                        controller: _serumInputCtrl,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Last Serum",
                        ),
                      ),
                    )
                  ),
                  MaterialButton(
                    onPressed: store,
                    child: Text('Set'),
                    color: Colors.blueAccent,
                    textColor: Colors.white,
                  ),
                  Container(
                    width: 40,
                    margin: EdgeInsets.only(left: 2.0),
                    child: FloatingActionButton(
                      onPressed: updateUI,
                      child: new Icon(Icons.refresh),
                    ),
                  )
                ],
              ),
            ),
            Center(
              child: Text(
                "$_replenishiedMsg"
              )
            ),
          ],
        ),
      ),
    );
  }
}
