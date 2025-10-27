

import 'package:flutter/material.dart';
import 'package:rotaxx/renkler.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/background_4.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40.0),
            child: AppBar(
              leadingWidth: 80,
              backgroundColor: kgriRenk,
              centerTitle: true,
              leading:
              Padding(padding: EdgeInsets.only(left: 10.0),
                child: Image.asset(
                  'assets/images/logo_1.png',
                  fit: BoxFit.contain,
                ),
              ),
              title:Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Welcome to ", style: TextStyle(
                      fontSize: 18,
                      color: kartRenk,
                      fontFamily: "Pacifico"
                  ),
                  ),
                  Text("ROTAX", style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 23,
                    color: kartRenk,
                  )
                  ),
                ],
              ),
            ),
          ),
        ),
        body:Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    print("Card tıklandı!");
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    height: 100,
                    width: 250,
                    child: Card(
                      color: kartRenk,
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child:
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.directions_car, color: siyahRenk, size: 40,), // Logo/Icon
                            SizedBox(width: 16),
                            Column(
                              children: [
                                Text(
                                  "DRIVER",
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: siyahRenk,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "(Sürücü)",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: siyahRenk,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                ),
                SizedBox(height: 40),
                InkWell(
                  onTap: () {
                    print("Card tıklandı!");
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    height: 100,
                    width: 250,
                    child: Card(
                      color: kartRenk,
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child:
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Row(
                          children: [
                            Icon(Icons.sell_rounded, color: siyahRenk, size: 40,), // Logo/Icon
                            SizedBox(width: 16),
                            Column(
                              children: [
                                Text(
                                  "DISTRIBUTOR",
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: siyahRenk,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "(Dağıtıcı)",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: siyahRenk,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                ),
                SizedBox(height: 40),
                InkWell(
                  onTap: () {
                    print("Card tıklandı!");
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    height: 100,
                    width: 250,
                    child: Card(
                      color: kartRenk,
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child:
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Row(
                          children: [
                            Icon(Icons.shop_2, color: siyahRenk, size: 40,), // Logo/Icon
                            SizedBox(width: 16),
                            Column(
                              children: [
                                Text(
                                  "Come & Take" ,
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: siyahRenk,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "(Gel-Al Noktası)",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: siyahRenk,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                ),
                SizedBox(height: 40),
                InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, '/register/registerPage');
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: anaRenk,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                    child: Text(
                      "Üye Ol!",
                      style: TextStyle(
                        fontSize: 20,
                        color: kartRenk,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
