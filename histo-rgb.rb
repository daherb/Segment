require 'imlib2'
require 'tk'

$max = 600

def usage
  puts "Usage: ruby histo.rb image";
  exit
end

if ARGV.size < 1 then
  usage
else
  $image = Imlib2::Image.load ARGV[0];
  $xcount = Array.new
  $ycount = Array.new
  0.upto $image.height do |y|
    $ycount[y] = Hash.new
  end
  0.upto $image.width do |x|
    $xcount[x] = Hash.new
  end
  0.upto $image.height do |y|
    0.upto $image.width do |x|
      color = $image.query_pixel x,y
      if $xcount[x][:r].nil? then
        $xcount[x][:r] = color.r
        $xcount[x][:g] = color.g
        $xcount[x][:b] = color.b
      else
        $xcount[x][:r] += color.r
        $xcount[x][:g] += color.g
        $xcount[x][:b] += color.b
      end
      if $ycount[y][:r].nil? then
        $ycount[y][:r] = color.r
        $ycount[y][:g] = color.g
        $ycount[y][:b] = color.b
      else
        $ycount[y][:r] += color.r
        $ycount[y][:g] += color.g
        $ycount[y][:b] += color.b
      end
    end
  end
  $nheight = $image.height
  $nwidth = $image.width
  if $image.width > $max then
    $nwidth = $max
    $nheight = $image.height.to_f / $image.width.to_f * $max.to_f
  end
  if $nheight > $max then
    $nwidth = $nwidth.to_f / $nheight.to_f * $max.to_f
    $nheight = $max
  end
  $xhisto = Imlib2::Image.new $image.width, 120
  $xhisto.fill_rect [0,0,$xhisto.width,$xhisto.height], Imlib2::Color::WHITE
  0.upto $xhisto.width do |x|
    ($xcount[x].sort_by { |colour, value| value }).reverse.each do |colour,value|
      if colour == :r then
        draw_colour = Imlib2::Color::RED
      elsif colour == :g then
        draw_colour = Imlib2::Color::GREEN
      elsif colour == :b then
        draw_colour = Imlib2::Color::BLUE
      else
        # No other colors
        puts 'There are no other colours, are there?'
      end
      $ypos = value.to_f / ( $image.height.to_f * 255.0 ) * 120.0
      $xhisto.draw_line x , $xhisto.height - $ypos.to_i, x, $xhisto.height, draw_colour
    end
  end
  $xhisto.crop_scaled! 0,0,$xhisto.width,$xhisto.height,$nwidth,120
  $xhisto.save '/tmp/segment-xhisto.ppm'
  $yhisto = Imlib2::Image.new 120, $image.height
  $yhisto.fill_rect [0,0,$yhisto.width,$yhisto.height], Imlib2::Color::WHITE
  0.upto $yhisto.height do |y|
    ($ycount[y].sort_by { |colour, value| value }).reverse.each do |colour,value|
      if colour == :r then
        draw_colour = Imlib2::Color::RED
      elsif colour == :g then
        draw_colour = Imlib2::Color::GREEN
      elsif colour == :b then
        draw_colour = Imlib2::Color::BLUE
      else
        # No other colors
        puts 'There are no other colours, are there?'
      end
      $xpos = value.to_f / ( $image.width.to_f * 255.0 ) * 120.0
      $yhisto.draw_line 0, y, $xpos , y, draw_colour
    end
  end
  $yhisto.crop_scaled! 0,0,$yhisto.width,$yhisto.height,120,$nheight
  $yhisto.save '/tmp/segment-yhisto.ppm'
  $preview = $image.crop_scaled 0, 0, $image.width, $image.height, $nwidth, $nheight
  $preview.save '/tmp/segment-preview.ppm'
  
  root = TkRoot.new do
    title "Colour Histrogram" 
    minsize($nwidth.to_i + 150,$nheight.to_i + 150)
  end
  preview_label = TkLabel.new(root)
  preview_label.image = TkPhotoImage.new(:file => '/tmp/segment-preview.ppm')
  preview_label.place('height' => $nheight.to_i, 'width' => $nwidth.to_i, 
                      'x' => 140, 'y' => 10)
  xhisto_label = TkLabel.new(root)
  xhisto_label.image = TkPhotoImage.new(:file => '/tmp/segment-xhisto.ppm')
  xhisto_label.place('height' => 120, 'width' => $nwidth.to_i, 
                     'x' => 140, 'y' => 20 + $nheight.to_i)
  yhisto_label = TkLabel.new(root)
  yhisto_label.image = TkPhotoImage.new(:file => '/tmp/segment-yhisto.ppm')
  yhisto_label.place('height' => $nheight.to_i, 'width' => 120, 
                     'x' => 10, 'y' => 10)
  #  puts $ycount
  Tk.mainloop
end
