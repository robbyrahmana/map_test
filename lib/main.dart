import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_praviaed/map_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

void main() {
  runApp(new MapsAed());
}

class MapsAed extends StatefulWidget {
  MapsAed() : super();

  final String title = "Aed Tomažič";

  @override
  MapsAedState createState() => MapsAedState();
}

class MapsAedState extends State<MapsAed> {
  Completer<GoogleMapController> _controler = Completer();
  static const LatLng _center = const LatLng(46.263554, 15.183443);
  final Set<Marker> _markers = {};
  LatLng _lastMapPosition = _center;
  MapType _currentMapType = MapType.normal;

  final _collectionReference = Firestore.instance.collection("position");
  final _controllerText = TextEditingController();

  static final CameraPosition _position1 = CameraPosition(
    bearing: 192.999,
    target: LatLng(46.263554, 15.183443),
    tilt: 59,
    zoom: 11.0,
  );

  Future<void> _goToPosition1() async {
    final GoogleMapController controller = await _controler.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_position1));
  }

  _onMapCreated(GoogleMapController controller) {
    _controler.complete(controller);
  }

  _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }

  _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  _onAddMarkerButtonPressed(String id, String title) {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId(id),
          position: _lastMapPosition,
          infoWindow: InfoWindow(
            title: title,
            snippet: '12',
          ),
          icon: BitmapDescriptor.defaultMarker,
        ),
      );
    });
  }

  Widget button(Function function, IconData icon) {
    return FloatingActionButton(
        onPressed: function,
        materialTapTargetSize: MaterialTapTargetSize.padded,
        backgroundColor: Colors.blue,
        child: Icon(
          icon,
          size: 36.0,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          backgroundColor: Colors.blue,
        ),
        body: StreamBuilder<Object>(
            stream: _collectionReference.snapshots(),
            builder: (context, snapshot) {
              return Stack(
                children: <Widget>[
                  GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: _center,
                      zoom: 11.0,
                    ),
                    mapType: _currentMapType,
                    markers: _markers,
                    onCameraMove: _onCameraMove,
                  ),
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Column(
                        children: <Widget>[
                          button(_onMapTypeButtonPressed, Icons.map),
                          SizedBox(
                            height: 16.0,
                          ),
                          button(() async {
                            String newid =
                                _collectionReference.document().documentID;
                            await _setNewMarker(context, newid);
                            _onAddMarkerButtonPressed(
                                newid, _controllerText.text);
                          }, Icons.add_location),
                          SizedBox(
                            height: 16.0,
                          ),
                          button(_goToPosition1, Icons.location_searching),
                        ],
                      ),
                    ),
                  )
                ],
              );
            }),
      ),
    );
  }

  Future _setNewMarker(BuildContext context, String newid) {
    _controllerText.clear();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: TextField(
              controller: _controllerText,
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("Save"),
                onPressed: () {
                  _collectionReference.document(newid).setData({
                    'id': newid,
                    'name': _controllerText.text,
                    'location': GeoPoint(
                        _lastMapPosition.latitude, _lastMapPosition.longitude),
                  });
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }
}
