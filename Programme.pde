// SRAIRI, YANIS - ISEL 3 - Groupe A - 13/12/2022

// Librairies
import java.util.*;

// Déclaration des constantes

// Déclaration des objets et des variables globales
String NMEA_ISEL="$GPGGA,145704.211,4929.401,N,00007.598,E,1,12,1.0,0.0,M,0.0,M,,*6F"; //entrée ISEL
String NMEA = "GPGGA,101451.000,4929.1158,N,00006.2806,E,1,6,1.77,88.7,M,47.0,M,,*6E";
PFont maPolice;
String[] list = split(NMEA,",");
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

// Initialisation
void setup()
{
  
  size(1055,597); surface.setTitle ("ISEL TP GPS - Yanis SRAIRI ISEL 3A");
  background(loadImage("mapLH_1055_597.JPG")); smooth();
  maPolice=createFont("Arial",14,true); textFont(maPolice,14);
  textFont(maPolice,32);
}

void draw()
{
  // CONVERSION DEGRE -> PIXEL (ISEL)
  String[] latlongISEL = conversion(list2[2], list2[4]);
  
  // CONVERSION DEGRE -> PIXEL (AUTRE POINT) 
  String[] latlong = conversion(list[2], list[4]);
  
  // QUESTION 1 - AFFICHAGE HEURE LATITUDE LONGITUDE
  println("Heure : "+ list[1].substring(0,2)+":" + list[1].substring(2,4) + ":" + list[1].substring(4,6));
  println("Latitude : "+ float(latlong[2]));
  println("Longitude : " + float(latlong[3]));
  
  // AFFICHE DES POINTS + RAYON AUTOUR DE L'ISEL
  fill(0,0,0,0); ellipse(float(latlongISEL[1]), float(latlongISEL[0]), 160, 160);
  fill(0,0,255); ellipse(float(latlongISEL[1]), float(latlongISEL[0]), 8, 8);
  fill(255,0,0); ellipse(float(latlong[1]),float(latlong[0]),8,8); 
  
  // CALCUL DE LA DISTANCE UTILISANT LA FONCTION
  float[] dist = discap(float(latlong[3]), float(latlong[2]), float(latlongISEL[3]), float(latlongISEL[2]));
  
  // ERREUR SI A L'EXTERIEUR DU CERCLE
  fill(0,0,255);
  if (dist[0] > 1000) {
    text("Vous êtes en dehors de la zone",300,100);
  } else {
    text("Vous êtes dans la zone", 300, 100);
  }
}
