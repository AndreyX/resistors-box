
// Resistors Box
// AndreyX

// Processing's XML library is used

// Main circles settings :
int circles_cnt = 25; // number of circles in a row
int circle_rows = 5; // number of row
float circle_radius_mm = 5; // circle radius (mm)
float circles_margin_mm = 3; // minimum distance between circles (mm)
float end_margin_mm = 5; // distance from last row to outer edge (mm)
float center_radius_mm = 1.5; // radius of the central circle (hole)

// Additional circle settings :
int inner_circles_cnt = 4; // number of inner circles
float inner_circles_radius_mm = 10; // radius of inner circles (additional) in mm
float inner_radius_mm = 20; // radius of the circle on which the inner circles are located

// Other settings :
boolean flat_parking = true; // determines whether to leave an empty space (1 row) for parking the lid or not
boolean place_centers = true; // determines whether to draw the centers of the circles or not


// Draw settings :
float px_per_mm = 2.5; // number of pixels in mm (draw density)
color background_color = #004ADB; // background color
color circles_color = #FFFFFF; // line color

// Operating variables :
Circle[] circles; // array for circles
int circles_count; // number of circles
float box_size_mm; // field size in mm
float box_size_px; // field size in px
float box_center_mm = 0; // field center in mm
float box_center_px = 0; // middle of the field in px
PFont box_font; // font
int box_margin = 10;
int box_bottom_margin = 30;
int box_font_size = 15;
int box_font_margin = 10;
int box_width_l = 7;

void settings() {
  
  // Calculation of all circles :
  calculate_circles();
  
  // Window definition :
  size( (int)box_size_px, ( (int)box_size_px - box_margin + box_bottom_margin ) );
  noLoop();

}

void setup() {

  // Load the font :
  box_font = createFont( "Consolas", 32, true );
  textFont( box_font );
  
}

void draw() {
  
  // Setting drawing parameters :
  background( background_color );
  stroke( circles_color );
  strokeWeight( 1 );
  noFill();
  ellipseMode( RADIUS );
  
  // Drawing circles :
  for ( int i = 0; i < circles_count; i++ ) {
    circles[i].draw();
  }
  
  // Write the width :
  textAlign( CENTER, CENTER );
  textSize( box_font_size );
  float text_y_px = box_size_px - box_margin + ( box_bottom_margin / 2 );
  String l_text = box_size_mm + " mm";
  float text_width = textWidth( l_text );
  line( box_margin, text_y_px, ( box_center_px - box_font_margin - text_width / 2 ), text_y_px );
  line( box_margin, ( text_y_px - box_width_l ), box_margin, ( text_y_px + box_width_l ) );
  line( ( box_center_px + box_font_margin + text_width / 2 ), text_y_px, ( box_size_px - box_margin ), text_y_px  );
  line( ( box_size_px - box_margin ), ( text_y_px - box_width_l ), ( box_size_px - box_margin ), ( text_y_px + box_width_l ) );
  text( l_text, box_center_px, text_y_px );
  
  // Save the image :
  save( "resistors_box.png" );
  
  // Create an SVG file :
  create_svg();
  
}

// Calculating circles and filling an array of objects :
void calculate_circles() {
  
  // Count the number of circles that will make up the final drawing :
  circles_count = ( circles_cnt * circle_rows ) + inner_circles_cnt + 2;
  if ( flat_parking ) circles_count = circles_count - circle_rows - 1;
  
  circles = new Circle[circles_count];
  int cur_circle_count = 0;
  
  // Calculate the angle between the holes :
  float circle_angle = 2 * PI / circles_cnt;
  
  // Converting dimensions to px :
  float half_angle = circle_angle / 2;
  
  // Calculation of the radius of the first row :
  float cur_radius_mm = ( ( 2 * circle_radius_mm ) + circles_margin_mm ) / ( 2 * sin( circle_angle / 2 ) );
  
  // Calculating circles :
  for ( int row = 0; row < circle_rows; row++ ) // go through all rows
  {

    // current offset angle :
    float cur_shift_angle = half_angle * row; 

    // count the current radius :
    if ( row > 0 ) {
      // count the current indents :
      float pre_radius_mm = cur_radius_mm;
      float pre_chord_mm = 2 * pre_radius_mm * sin( circle_angle / 2 ); // chord length of the previous row
      float cur_margin_mm = sqrt( sq( ( 2 * circle_radius_mm ) + circles_margin_mm ) - sq( pre_chord_mm / 2 ) ); // indentation of the current row from the previous one
      cur_radius_mm = cur_radius_mm + cur_margin_mm; // radius of the current row in mm
    }

    for ( int i = 1; i <= circles_cnt; i++ ) // go through all circles of the row
    {
      if ( ! flat_parking || i != 1 ) {
        float cur_angle = ( circle_angle * (int)( i - 1 ) ) + cur_shift_angle; // current circle angle
        float cur_x_mm = 0 + ( cur_radius_mm * cos( cur_angle ) ); // X coordinate of the current circle in mm
        float cur_y_mm = 0 + ( cur_radius_mm * sin( cur_angle ) ); // Y coordinate of the current circle in mm
        circles[cur_circle_count] = new Circle( cur_x_mm, cur_y_mm, circle_radius_mm );
        cur_circle_count ++;
      }
    }

  }
  
  // Inner circles (additional) :
  if ( inner_circles_cnt > 0 )
  {
    float inner_circle_angle = 2 * PI / inner_circles_cnt;
    for ( int i = 1; i <= inner_circles_cnt; i++ )
    {
      if ( ! flat_parking || i != 1 ) {
        float cur_angle = inner_circle_angle * (int)( i - 1 ); // angle of the current inner circle
        float cur_x_mm = ( inner_radius_mm * cos( cur_angle ) ); // X coordinate of the current inner circle in mm
        float cur_y_mm = ( inner_radius_mm * sin( cur_angle ) ); // Y coordinate of the current inner circle in mm
        circles[cur_circle_count] = new Circle( cur_x_mm, cur_y_mm, inner_circles_radius_mm );
        cur_circle_count ++;
      }
    }    
  }
  
  // Outer circle :
  float end_radius_mm = circle_radius_mm + cur_radius_mm + end_margin_mm;
  circles[cur_circle_count] = new Circle( 0, 0, end_radius_mm );
  cur_circle_count ++;
  box_size_mm = end_radius_mm * 2;
  box_center_mm = end_radius_mm;
  box_size_px = box_size_mm * px_per_mm + ( box_margin * 2 );
  box_center_px = box_size_px / 2;
  
  // Central circle (hole) :
  circles[cur_circle_count] = new Circle( 0, 0, center_radius_mm );
  cur_circle_count ++;
  
}

// Creating an SVG file :
void create_svg() {
  String[] svg = new String[ ( circles_count + 3 ) ];
  svg[0] = "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>";
  svg[1] = "<svg version = \"1.1\" baseProfile=\"full\" xmlns = \"http://www.w3.org/2000/svg\" xmlns:xlink = \"http://www.w3.org/1999/xlink\" xmlns:ev = \"http://www.w3.org/2001/xml-events\" height = \"" + box_size_mm + "mm\"  width = \"" + box_size_mm + "mm\">";
  int cur_i = 2;
  for ( int i = 0; i < circles_count; i++ ) {
    svg[ cur_i ] = "<circle cx=\"" + ( box_center_mm + circles[ i ].x ) + "mm\" cy=\"" + ( box_center_mm + circles[ i ].y ) + "mm\" r=\"" + circles[ i ].radius + "mm\" fill=\"none\" stroke-width=\"0.1mm\" stroke=\"rgb(0,0,0)\" />";
    cur_i ++;
  }
  svg[ ( cur_i ) ] = "</svg>";
  saveStrings( "resistors_box.svg", svg ); 
}

// Class for circles :
class Circle {
  float x;            // X coordinate of the center in mm
  float y;            // Y coordinate of the center in mm
  float radius;       // radius in mm
  float x_px;         // X coordinate in pixels
  float y_px;         // Y coordinate in pixels
  float radius_px;    // radius in pixels
  

  // Creating a Circle Object :
  Circle( float x_t, float y_t, float radius_t ) {
    x = x_t;
    y = y_t;
    radius = radius_t;
    
    radius_px = radius * px_per_mm;
  }
  
  // Drawing a circle :
  void draw() {
    x_px = x * px_per_mm + box_center_px;
    y_px = y * px_per_mm + box_center_px;
    ellipse( x_px, y_px, radius_px, radius_px ); // draw the circle itself
    if ( place_centers ) point( x_px, y_px ); // draw the center
  }
  
}
