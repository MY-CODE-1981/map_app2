import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:map_app2/place.dart';
import 'package:map_app2/searched_list_page.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController _controller;
  final TextEditingController _txtController = TextEditingController();
  String distance = '0.0';
  static const CameraPosition _initialPosition = CameraPosition(
      target: LatLng(35.85923914455456, 139.6572075665734),
      zoom: 16
  );

  String? errorTxt;
  Place? searchedPlace;

  late final CameraPosition currentPosition;
  Future<void> getCurrentPosition() async{
    LocationPermission permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.denied){
      permission = await Geolocator.requestPermission();
      if(permission == LocationPermission.denied){
        return Future.error('現在値を取得できません');
      }
    }
    final Position _currentPosition = await Geolocator.getCurrentPosition();
    currentPosition = CameraPosition(target: LatLng(_currentPosition.latitude, _currentPosition.longitude), zoom: 16);
  }

  final Set<Marker> _markers = {
    // const Marker(
    //   markerId: MarkerId('1'),
    //   position: LatLng(35.861363454432464, 139.65951910304224),
    //   infoWindow: InfoWindow(title: '自宅', snippet: '自宅はこちら')
    // ),
    // const Marker(
    //   markerId: MarkerId('2'),
    //   position: LatLng(35.860036905663584, 139.6604900627075),
    //   infoWindow: InfoWindow(title: '駐車場', snippet: '駐車場はこちら')
    // ),
  };

  Future<CameraPosition> searchedLatLng(String txt) async{
    List<Location> locations= await locationFromAddress(txt);
    return CameraPosition(target: LatLng(locations[0].latitude, locations[0].longitude), zoom: 16);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color:Colors.black),
        elevation: 0.0,
        backgroundColor: Colors.white,
        title:
        SizedBox(
          height: 40,
          child: TextField(
              controller: _txtController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.only(left: 10)
              ),
              onTap: () async{
                Place? result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchedListPage()));
                setState((){
                  searchedPlace = result;
                });
                if(searchedPlace != null){
                  _txtController.text = searchedPlace!.name!;
                  CameraPosition searchedPosition = await searchedLatLng(searchedPlace!.address ?? '');
                  setState((){
                    _markers.add(Marker(
                      markerId: const MarkerId('3'),
                      position: searchedPosition.target,
                      infoWindow: const InfoWindow(title: '検索結果')
                    ));
                  });
                  _controller.animateCamera(CameraUpdate.newCameraPosition(searchedPosition));
                  double _distance = Geolocator.distanceBetween(
                      currentPosition.target.latitude,
                      currentPosition.target.longitude,
                      searchedPosition.target.latitude,
                      searchedPosition.target.longitude
                  );
                  distance = (_distance / 1000).toStringAsFixed(1);
                }
              }
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            errorTxt == null ? Container() : Text(errorTxt!),
            searchedPlace == null ? Container() : SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: searchedPlace!.images.length,
                itemBuilder: (context, index) {
                  return Image.memory(searchedPlace!.images[index]!);
                }
              ),
            ),
            Expanded(
              child: GoogleMap(
                markers: _markers,
                // mapType: MapType.normal,
                initialCameraPosition: _initialPosition,
                onMapCreated: (GoogleMapController controller) async{
                  await getCurrentPosition();
                  _controller = controller;
                  // setState((){
                  //   _markers.add(Marker(
                  //       markerId: const MarkerId('3'),
                  //       position: currentPosition.target,
                  //       infoWindow: const InfoWindow(title: '現在地')
                  //   ));
                  // });
                  _controller.animateCamera(CameraUpdate.newCameraPosition(currentPosition));
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(distance + 'km')
            )
          ],
        ),
      )
    );
  }
}
