
// Resistors Box
// AndreyX

// Используется XML библиотека Processing'а

// Настройки основных кругов :
int circles_cnt = 25; // количество кругов в ряде
int circle_rows = 5; // количество рядов
float circle_radius_mm = 5; // радиус кругов в мм
float circles_margin_mm = 3; // минимальное расстояние между кругами в мм
float end_margin_mm = 5; // расстояние от последнего ряда до внешнего края в мм
float center_radius_mm = 1.5; // радиус центрального круга (отверстия)

// Настройки дополнительных кругов :
int inner_circles_cnt = 4; // количество внутренних кругов
float inner_circles_radius_mm = 10; // радиус внутренних кругов (дополнительных) в мм
float inner_radius_mm = 20; // радиус окружности, на которой расположены внутренние круги

// Другие настройки :
boolean flat_parking = true; // определяет оставлять пустое место (1 ряд) для парковки крышки или нет
boolean place_centers = true; // определяет отрисовывать центры кругов или нет


// Настройки отрисовки :
float px_per_mm = 2.5; // количество пикселей в мм (плотность отрисовки)
color background_color = #004ADB; // цвет заднего фона
color circles_color = #FFFFFF; // цвет линий

// Рабочие переменные :
Circle[] circles; // массив для кругов
int circles_count; // количество кругов
float box_size_mm; // размер поля в мм
float box_size_px; // размер поля в px
float box_center_mm = 0; // середина поля в мм
float box_center_px = 0; // середина поля в px
PFont box_font; // шрифт
int box_margin = 10;
int box_bottom_margin = 30;
int box_font_size = 15;
int box_font_margin = 10;
int box_width_l = 7;

void settings() {
  
  // Рассчет всех кругов :
  calculate_circles();
  
  // Задание окна :
  size( (int)box_size_px, ( (int)box_size_px - box_margin + box_bottom_margin ) );
  noLoop();

}

void setup() {

  // загружаем шрифт :
  box_font = createFont( "Consolas", 32, true );
  textFont( box_font );
  
}

void draw() {
  
  // Задаем параметры рисования :
  background( background_color );
  stroke( circles_color );
  strokeWeight( 1 );
  noFill();
  ellipseMode( RADIUS );
  
  // Отрисовываем круги :
  for ( int i = 0; i < circles_count; i++ ) {
    circles[i].draw();
  }
  
  // Подписываем ширину :
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
  
  // Сохраняем изображение :
  save( "resistors_box.png" );
  
  // Создаем SVG файл :
  create_svg();
  
}

// Рассчет кругов и заполнение массива объектов :
void calculate_circles() {
  
  // Считаем количество кругов, из которых будет состоять конечный рисунок :
  circles_count = ( circles_cnt * circle_rows ) + inner_circles_cnt + 2;
  if ( flat_parking ) circles_count = circles_count - circle_rows - 1;
  
  circles = new Circle[circles_count];
  int cur_circle_count = 0;
  
  // Считаем угол между отверстиями :
  float circle_angle = 2 * PI / circles_cnt;
  
  // Пересчитываем размеры в px :
  float half_angle = circle_angle / 2;
  
  // Рассчет радиуса первого ряда :
  float cur_radius_mm = ( ( 2 * circle_radius_mm ) + circles_margin_mm ) / ( 2 * sin( circle_angle / 2 ) );
  
  // Рассчитываем круги :
  for ( int row = 0; row < circle_rows; row++ ) // проход по всем рядам
  {

    // текущий угол смещения :
    float cur_shift_angle = half_angle * row; 

    // считаем текущий радиус :
    if ( row > 0 ) {
      // считаем текущие отступы :
      float pre_radius_mm = cur_radius_mm;
      float pre_chord_mm = 2 * pre_radius_mm * sin( circle_angle / 2 ); // длина хорды предыдущего ряда
      float cur_margin_mm = sqrt( sq( ( 2 * circle_radius_mm ) + circles_margin_mm ) - sq( pre_chord_mm / 2 ) ); // отступ текущего ряда от предыдущего
      cur_radius_mm = cur_radius_mm + cur_margin_mm; // радиус текущего ряда в мм
    }

    for ( int i = 1; i <= circles_cnt; i++ ) // проход по всем кругам ряда
    {
      if ( ! flat_parking || i != 1 ) {
        float cur_angle = ( circle_angle * (int)( i - 1 ) ) + cur_shift_angle; // угол текущего круга
        float cur_x_mm = 0 + ( cur_radius_mm * cos( cur_angle ) ); // координата X текущего круга в мм
        float cur_y_mm = 0 + ( cur_radius_mm * sin( cur_angle ) ); // координата Y текущего круга в мм
        circles[cur_circle_count] = new Circle( cur_x_mm, cur_y_mm, circle_radius_mm );
        cur_circle_count ++;
      }
    }

  }
  
  // Внутренние круги (дополнительные) :
  if ( inner_circles_cnt > 0 )
  {
    float inner_circle_angle = 2 * PI / inner_circles_cnt;
    for ( int i = 1; i <= inner_circles_cnt; i++ )
    {
      if ( ! flat_parking || i != 1 ) {
        float cur_angle = inner_circle_angle * (int)( i - 1 ); // угол текущего внутреннего круга
        float cur_x_mm = ( inner_radius_mm * cos( cur_angle ) ); // координата X текущего внутреннего круга в мм
        float cur_y_mm = ( inner_radius_mm * sin( cur_angle ) ); // координата Y текущего внутреннего круга в мм
        circles[cur_circle_count] = new Circle( cur_x_mm, cur_y_mm, inner_circles_radius_mm );
        cur_circle_count ++;
      }
    }    
  }
  
  // Внешний круг :
  float end_radius_mm = circle_radius_mm + cur_radius_mm + end_margin_mm;
  circles[cur_circle_count] = new Circle( 0, 0, end_radius_mm );
  cur_circle_count ++;
  box_size_mm = end_radius_mm * 2;
  box_center_mm = end_radius_mm;
  box_size_px = box_size_mm * px_per_mm + ( box_margin * 2 );
  box_center_px = box_size_px / 2;
  
  // Центральный круг (отверстие) :
  circles[cur_circle_count] = new Circle( 0, 0, center_radius_mm );
  cur_circle_count ++;
  
}

// Создание SVG файла :
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

// Класс для кругов :
class Circle {
  float x;            // координата X центра в мм
  float y;            // координата Y центра в мм
  float radius;       // радиус в мм
  float x_px;         // координата X в пикселях
  float y_px;         // координата Y в пикселях
  float radius_px;    // радиус в пикселях
  

  // Создание объекта круга :
  Circle( float x_t, float y_t, float radius_t ) {
    x = x_t;
    y = y_t;
    radius = radius_t;
    
    radius_px = radius * px_per_mm;
  }
  
  // Отрисовка круга :
  void draw() {
    x_px = x * px_per_mm + box_center_px;
    y_px = y * px_per_mm + box_center_px;
    ellipse( x_px, y_px, radius_px, radius_px ); // рисуем сам круг
    if ( place_centers ) point( x_px, y_px ); // рисуем центр
  }
  
}
