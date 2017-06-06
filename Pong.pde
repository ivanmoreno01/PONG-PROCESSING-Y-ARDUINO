import processing.serial.*;
 
// importamos la librería
import ddf.minim.*;
 
// Declaramos objeto musica de tipo Minim
Minim musica;
 
// Declaramos las canciones de tipo Audioplayer
AudioPlayer cancion1;
 
 
int bgcolor;       	// Background color       	// Fill color
Serial myPort;                 	// The serial port
int[] serialInArray = new int[2];  // Where we'll put what we receive
int serialCount = 0;           	// A count of how many bytes we receive
float ypos1=150;
float ypos2=150;             	// Starting position of the ball
boolean firstContact = false; // Whether we've heard from the microcontroller
float bolaX; //posición de la bola
float bolay;
float velx=4;   //velocidad de la bola
float vely=4;
float ballpos1;      //posicion de la bola
float ballpos2;
int marcadorlocal=0;
int marcadorvisitante=0;
int nivel=0;
float ypala1;               // posición en eje y de la pala1
float ypala2;                              // posición en eje y de la pala2
 
boolean tamanolocal=false;             //variable para el cambio de tamaño del marcadorlocal
float texsize=30;
boolean tamanovisitante=false;     //variable para el cambio de tamaño del marcador visitante
float texsize=30;                               //variable para el cambio del tamaño del texto
 
boolean gol=false;
 
//variables para la función millis
int tiempoActual=0;                          
int tiempoPrevio=0;
int interval=2000;
 
//variables para fijar el tamaño del texto
int tamanoTextoL=40;
int tamanoTextoV=40;
int t=0;
 
int letra=0;
 
boolean texto=false;
 
//función random
int randomR;
int randomG;
int randomB;
 
 
 
 
 
//clones
Pelota miPelota1;
Pelota miPelota2;
Pelota miPelota3;
Pelota miPelota4;
Pelota miPelota5;
 
 
 
void setup() {
  size(1200, 600);  // Stage size
	// creamos el objeto musica de tipo Minim
  musica = new Minim(this);
  // cargamos las canciones
  cancion1 = musica.loadFile("01.mp3");
  cancion1.loop();
 cancion1.pause();
 
 
 //cracion de nuevas pelotas clonizadas
  miPelota1= new Pelota(width/4, height/2);
  miPelota2= new Pelota(width*3/4, height/2);
  miPelota3= new Pelota(width*2/4, height/2);
  miPelota4= new Pelota(width*1/4, height/2);
  miPelota5= new Pelota(width*1.5/4, height/2);
 
 //posición al comienzo y diseño de la bola 
  bolaX=width/2;
  bolay=height/2;
  noStroke();	// No border on the next thing drawn
  
//llamada a función de presentación
presentacion();
 
 
  // Print a list of the serial ports, for debugging purposes:
  printArray(Serial.list());
 
  // I know that the first port in the serial list on my mac
  // is always my  FTDI adaptor, so I open Serial.list()[0].
  // On Windows machines, this generally opens COM1.
  // Open whatever port is the one you're using.
  String portName = Serial.list()[0];
  myPort = new Serial(this, portName, 9600);
 
 
 
}
 
void draw() {
 
//secuencia de pantallas
  switch (nivel) {
  case 0:
	presentacion();
    
	cancion1.play();
 
	break;
  case 1:
	juego();
	cancion1.pause();
 
	break;
  case 2:
	ganadorlocal();
	cancion1.pause();
	break;
  case 3:
	ganadorvisitante();
	cancion1.pause();
	break;
  }
}
 
 //función presentación
void presentacion() {
  background(0);
  strokeWeight(1);
  textAlign(CENTER);
  textSize(texsize);
  fill(ypos1, ypos2, (ypos1+ypos2)/2);
  text("PING PONG", width/2, height*1/3);
  textSize(25);
  text("Pega las palas al sensor para empezar", width/2, height*2/3);
 
  if (texsize>100) {
	texto=true;
  }
  if (texsize<20) {
	texto=false;
  }
 
  if (texto==true) {
	texsize=texsize-0.5;
  }
  if (texto==false) {
	texsize=texsize+0.5;
  }
 
  if (ypos1<30 && ypos2<30) {
	delay(2000);
	nivel=1;
  }
 
  //parte clon
  miPelota1.move();
  miPelota2.move();
  miPelota3.move();
  miPelota4.move();
  miPelota5.move();
  miPelota1.display();
  miPelota2.display();
  miPelota3.display();
  miPelota4.display();
  miPelota5.display();
}
 
 
 
 
 //función del nivel del juego
void juego() {
  dibujarfondo();
  dibujarpaletas();
  movimientopelota();
  contactoconpadel();
  rebote();
  scores(); //LINEA 200
  goal();
  findeljuego();
}
 //dibujos
void dibujarpaletas() {
  fill(255);
  // Draw the shape
  rect(10, ypala1, 5, 90);
  rect(width-15, ypala2, 5, 90);
  ellipse(bolaX, bolay, 20, 20);
}
 //fisica del juego
void movimientopelota() {
  //mover pelota
  bolaX=bolaX+velx; //veloc de la bola para el eje x
  bolay=bolay+vely;  //veloc de la bola para eje y
  if (velx<0 && velx>-15) {
 
	velx=velx-0.005;
	vely=vely-0.005;
  }
 
  if (velx>0 && velx<15) {
	velx=velx+0.005;
	vely=vely+0.005;
  }
}
 
void contactoconpadel() {
  // comentado
  ballpos1=ypala1+90;
  ballpos2=ypala2+90;
  // if anidado x y if y
  if (bolay>ypala1-20 && bolay<ballpos1+20 && bolaX<15) { 	//contacto de la bola con el padel1
	velx=-velx;
  }
  if (bolay>ypala2-20 && bolay<ballpos2+20 && bolaX>width-20) {   //contacto de la bola con el padel2
	velx=-velx;
  }
}
 
// chequeamos rebote techo y suelo
void rebote() {
 
  if ( bolay<10) {   //rebote en la parte izquierda
	vely=-vely;
  }
  if (bolay>height-10) {
	vely=-vely;
	//parte derecha
  }
}
 //funcion de gol
void goal() {
 
  if (bolaX>width) {
	t=1;
	tiempoPrevio=millis();
	marcadorvisitante = marcadorvisitante + 1;
	bolaX=width/2; // pelota en el centro
	bolay=height/2;
	velx=0;  //velocidad de la bola
	vely=0;
	tamanoTextoL=40;
	tamanoTextoV=80;
	letra=1;
  }
 
  if (t==1) {
 
	tiempoActual = millis(); // se graba el tiempo actual
 
	if (tiempoActual - tiempoPrevio >= interval) {
 
  	tamanoTextoL=40;
  	tamanoTextoV=40;
  	velx=-4;   //velocidad de la bola
  	vely=4;
  	t=0;
	}
  }
 
 
  if (bolaX <0) {
 
	t=2;
	tiempoPrevio=millis();
	marcadorlocal = marcadorlocal + 1;
	bolaX=width/2; // pelota en el centro
	bolay=height/2;
	velx=0;  //velocidad de la bola
	vely=0;
	
//cambio de tamaño de marcador 
tamanoTextoL=80;
	tamanoTextoV=40;
	letra=2;
  }
  if (t==2) {
	tiempoActual = millis(); // se graba el tiempo actual
 
	if (tiempoActual - tiempoPrevio >= interval) {
 
  	tamanoTextoL=40;
  	tamanoTextoV=40;
  	velx=4;   //velocidad de la bola
  	vely=4;
  	t=0;
	}
  }
}
 
 
 //funcion del marcador en goles
void scores() {
 
  textAlign(CENTER);
  //marcadores
  fill (200);
  textSize(tamanoTextoL);
  text (marcadorlocal, 750, 75);
  textSize(tamanoTextoV);
  text (marcadorvisitante, 450, 75);
 
 
  //parte de los jugadores
  fill(100);
  textSize(40);
  text("JUGADOR 1", 200, 75);
  text("JUGADOR 2", 1000, 75);
}
 
 
void dibujarfondo() {
  background(#0ECB52);
 
  // Dibujar
 
  stroke(255, 255, 255);
  //linea del mediocentro
  strokeWeight(10);
  line(600, 0, 600, 600);
  //area de la izquierda
 
  //linea a
  stroke(255, 255, 255);
  strokeWeight(10);
  line(0, 150, 300, 150);
 
  //linea b
  stroke(255, 255, 255);
  strokeWeight(10);
  line(0, 450, 300, 450);
 
  //linea c
  stroke(255, 255, 255);
  strokeWeight(10);
  line(300, 150, 300, 450);
  //area de la derecha
 
  //linea a
  stroke(255, 255, 255);
  strokeWeight(10);
  line(1200, 150, 900, 150);
 
  //linea b
  stroke(255, 255, 255);
  strokeWeight(10);
  line(1200, 450, 900, 450);
 
  //linea c
  stroke(255, 255, 255);
  strokeWeight(10);
  line(900, 150, 900, 450);
}
 
void findeljuego() {
  if (marcadorlocal>6) {
	nivel=nivel+1;
	ganadorlocal();
  }
  if (marcadorvisitante>6) {
	nivel=nivel+2;
	ganadorvisitante();
  }
}
 //pantalla del ganador local
void ganadorlocal() {
  background(#57D8A1);
  //textos
  fill(#F2ED42);
  textAlign(CENTER);
  textSize(60);
  text("JUGADOR 2 GANA", width/2, height*1/4);
  textSize(100);
  text(marcadorvisitante, width*1/4, height*5/8);  
  text("-", width/2, height*5/8);
  text(marcadorlocal, width*3/4, height*5/8);
  textSize(20);
  text("Pulsa espacio para jugar otra vez", width/2, height*7/8);
 
  if (key==' ') {
	nivel=0;
	marcadorlocal=0;
	marcadorvisitante=0;
  }
}
 
 
 //pantalla del ganador visitante
void ganadorvisitante() {
  background(#57D8A1);
  //textos
  fill(#F2ED42);
  textAlign(CENTER);
  textSize(60);
  text("JUGADOR 1 GANA", width/2, height*1/4);
  textSize(100);
  text(marcadorvisitante, width/4, height*5/8);  
  text("-", width/2, height*5/8);
  text(marcadorlocal, width*3/4, height*5/8);
  textSize(20);
 
//función de reinicio
 
  text("Pulsa espacio para jugar otra vez", width/2, height*7/8);
 
  if (key==' ') {
	nivel=0;
	marcadorlocal=0;
	marcadorvisitante=0;
  }
}
 
 
 //Parte de comunicación de processing y arduino
 
void serialEvent(Serial myPort) {
  // read a byte from the serial port:
  int inByte = myPort.read();
  // if this is the first byte received, and it's an A,
  // clear the serial buffer and note that you've
  // had first contact from the microcontroller.
  // Otherwise, add the incoming byte to the array:
  // PARA ESTABLECER PRIMER CONTACTO
  if (firstContact == false) {
	if (inByte == 'A') {
  	myPort.clear();    	// clear the serial port buffer
  	firstContact = true;   // you've had first contact from the microcontroller
  	myPort.write('A'); 	// ask for more
	}
  } else {
	// Add the latest byte from the serial port to array:
	serialInArray[serialCount] = inByte;
	serialCount++;
 
	// If we have 3 bytes:
	if (serialCount > 1 ) {
  	ypos1 = serialInArray[0];
  	ypos2 = serialInArray[1];
 
  	// print the values (for debugging purposes only):
  	// println(ypos1 + "\t" + ypos2);
 
  	// Send a capital A to request new sensor readings:
  	myPort.write('A');
  	// Reset serialCount:
  	serialCount = 0;
	}
  }
  ypala1=(height*ypos1)/255;
  ypala2=(height*ypos2)/255;
}
 
//parte de clones
 
class Pelota {
  // DATOS
  float xpos;  // posicion x de la pelota
  float ypos;  // posicion y de la pelotq
  color c;
  float vx;  // velocidad x pelota
  float vy;  // velocidad y pelota
  float diameter;
  float r;
  float g;
  float b;
 
  // CONSTRUCTOR
  Pelota(float xposTemp, float yposTemp) {
	c=color (255);
	//posición random
xpos=xposTemp;
	ypos=yposTemp;
	
//velocidad random
vx=random(-5, 5);
	vy=random(-5, 5);  
	diameter= 35;
//colores random	
r=random(0, 255);
	g=random(0, 255);
	b=random(0, 255);
  }
  // FUNCIONES
  void display() {
 
	fill(c);
	stroke(r, g, b);
	strokeWeight(2);
	ellipse(xpos, ypos, diameter, diameter);
  }
 
  void move() {
	xpos=xpos+vx;
	ypos=ypos+vy;
	if ((xpos>width-diameter/2)||(xpos-diameter/2<0)) {
  	vx=-vx;
	}   
	if ((ypos>height-diameter/2)||(ypos-diameter/2<0)) {
  	vy=-vy;
	}
  }
}
 
 
 
 
