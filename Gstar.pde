// SRAIRI Yanis - ISEL 3A
// Processing - Reception GPS GStar

// Librairies
import java.util.*;
import processing.serial.*;

// Déclaration des objets et des variables globales
Serial myPort; // objet port série
PFont maPolice;
String NMEA_ISEL="$GPGGA,145704.211,4929.401,N,00007.598,E,1,12,1.0,0.0,M,0.0,M,,*6F"; //entrée ISEL
String TrameGPGGA="";
String[] list2 = split(NMEA_ISEL, ",");
float dist;

// Fonction "Haversine"
float[] discap(float oLon, float oLat, float tLon, float tLat)
{
float[] distbear=new float[2];
float R_EARTH=6378137;
float dLon=0.0, dLat=0.0, dx=0.0, dy=0.0, aHarv=0.0, cHarv=0.0;
// Distance
dLon=radians(tLon-oLon); dLat=radians(tLat-oLat);
aHarv=sin(dLat/2.0)*sin(dLat/2.0)+cos(radians(oLat))*cos(radians(tLat))*sin(dLon/2)*sin(dLon/2);
cHarv=2*atan2(sqrt(aHarv),sqrt(1.0-aHarv));
distbear[0]=R_EARTH*cHarv; // distance
// Bearing
dx=cos(radians(oLat))*sin(radians(tLat))-sin(radians(oLat))*cos(radians(tLat))*cos(dLon);
dy=sin(dLon)*cos(radians(tLat));
distbear[1]=atan2(dy,dx); // cap
return distbear;
}


// Conversion degré sexagésimaux -> degré distance -> pixel
String[] conversion(String lati, String longi)
{
   String heure[] = new String[2];
   String minute[] = new String[2];
   String px[] = new String[4];
   
   heure[0] = lati.substring(0,2);
   heure[1] = longi.substring(0,3);
   minute[0] = lati.substring(2);
   minute[1] = longi.substring(3);

   float long1 = float(heure[1])+float(minute[1])/60;
   float lat1 = float(heure[0])+float(minute[0])/60;
   
   // px[1] longitude_pixel px[0] latitude_pixel px[3] longitude_dd px[4] lattitude_dd
   px[1] = str(5825.40739*long1-329.999354);
   px[0] = str(-8937.67019*lat1+442769.522);
   px[2] = str(lat1);
   px[3] = str(long1);
   
   return px;
}

// Fonctions
String extractTrames(String typeTrame)
{
  String inBuffer="", trame="", saveTrame=""; String[] list; boolean debTrame=false, finTrame=false, trameok=false;

  while (trameok==false) 
  {
    delay(50); 
    while (myPort.available()>0) // myPort.available() retourne le nombre d'octets reçus
    {
      inBuffer = myPort.readString(); 
      for(int i = 0; i < inBuffer.length(); i++)
      {
        // detection début trame NMEA183
        if (inBuffer.charAt(i)=='$') debTrame=true; 
        // detection fin trame NMEA183
        if ((inBuffer.charAt(i)=='\r')&&(debTrame==true)) finTrame = true; 
        // concaténation des octets constituant la trame
        if ((debTrame==true)&&(finTrame==false)) trame+=inBuffer.charAt(i);
        if (finTrame==true)
        {
          list=split(trame,','); 
          if (list[0].equals(typeTrame)) {saveTrame=trame; trameok=true;}
          trame=""; debTrame = false; finTrame = false;
        }
      }
    }
  }
  return saveTrame;
}

// Initialisations
void setup()
{
  size(1055,597); surface.setTitle("ISEL TP GPS - Yanis SRAIRI ISEL 3A"); // Taille et titre de la fenêtre
  background(loadImage("mapLH_1055_597.JPG")); smooth();
  maPolice=createFont ("Arial",14,true); textFont(maPolice,14); // Police de caractères
  printArray(Serial.list());
  myPort = new Serial(this,Serial.list()[0],4800,'N',8,1.0); // Port COM1 par défaut
  textFont(maPolice,32);
}

// Programme principal
void draw()
{
    // RECUPERATION TRAME GPS
    TrameGPGGA=extractTrames("$GPGGA");
    String[] list = split(TrameGPGGA,",");
    
    // CONVERSION DEGRE -> PIXEL (ISEL)
    String[] latlongISEL = conversion(list2[2], list2[4]);
  
    // CONVERSION DEGRE -> PIXEL (AUTRE POINT) 
    String[] latlong = conversion(list[2], list[4]);
    
    // QUESTION 1 - AFFICHAGE HEURE LATITUDE LONGITUDE
    println("Heure : "+ list[1].substring(0,2)+":" + list[1].substring(2,4) + ":" + list[1].substring(4,6));
    println("Latitude : "+ float(latlong[2]));
    println("Longitude : " + float(latlong[3]));
    
    // AFFICHE DES POITNS + RAYON AUTOUR DE L'ISEL
    fill(0,0,0,0); ellipse(float(latlongISEL[1]), float(latlongISEL[0]), 160, 160);
    fill(0,0,255); ellipse(float(latlongISEL[1]), float(latlongISEL[0]), 8, 8);
    fill(255,0,0); ellipse(float(latlong[1]),float(latlong[0]),8,8); 
    
    // CALCUL DE LA DISTANCE
    float[] dist = discap(float(latlong[3]), float(latlong[2]), float(latlongISEL[3]), float(latlongISEL[2]));
    
    fill(0,0,255);
    if (dist[0] > 1000) {
      text("Vous êtes en dehors de la zone", 300, 100);
    } else {
      text("Vous êtes dans la zone", 300, 100);
    } 
    
    // RECHARGER L'IMAGE POUR EFFACER LES ELEMENTS PRECEDEMMENT AFFICHE 
    background(loadImage("mapLH_1055_597.JPG")); smooth();
}
