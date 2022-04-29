
<!DOCTYPE html>
<html lang="en" class="notranslate" translate="no">

<head>
  <meta charset="utf-8" />
  <meta name="google" content="notranslate" />

  <title>Slider JSON</title>

  <link rel="stylesheet" href="swiper/swiper-bundle.css">
  <link rel="stylesheet" href="swiper-slide.css">

</head>

<body>
  <!-- Swiper -->
  <div class="swiper-container">
    <div class="swiper-wrapper">
      {% for slide in slides %}
	    <div class="swiper-slide" {% if slide.duration is defined %} data-swiper-autoplay="{{ slide.duration }}" {% endif %}>
		    {% if 'text' == slide.type %}
		    	{{ slide.msg|raw }}
		    {% elseif 'iframe' == slide.type %}
			<iframe title="Silde-Iframe" width="100%" height="100%" src="{{ slide.url }}"></iframe>
		    {% elseif 'img' == slide.type %}
			<img data-src="{{ slide.url }}" class="swiper-lazy" style='height: 100%; width: 100%; object-fit: contain'>
			<div class="swiper-lazy-preloader"></div>
		    {% elseif 'video' == slide.type %}
			<!-- video max-width='100%' max-height='100%' controls muted -->
			<video max-width='100%' max-height='100%' muted controls>
				<source src="{{ slide.url }}" type="video/mp4">
			</video>	
		    {% else %}
			Slide type not managed : {{ slide.type }}
		    {% endif %}
	    </div>
      {% endfor %}
    </div>
    <!-- Add Pagination -->
    <div class="swiper-pagination"></div>
  </div>

  <!-- Swiper JS -->
  <script src="swiper/swiper-bundle.js"></script>

  <!-- Initialize Swiper -->
  <script>
    function onVideoEnd() {
	  swiper.slideNext();
	  swiper.autoplay.start();
    }
    function onSlideChange(swip) {
	document.querySelectorAll('video').forEach(video => {
		video.pause();
		video.currentTime = 0;
	});
    };
    function onSlideChangeTransitionEnd (swip) {
	swip.slides[swip.activeIndex].querySelectorAll('video').forEach(video => {
	  swip.autoplay.stop();
	  video.play();
	  //video.muted=false;
	  //video.addEventListener('ended', onVideoEnd);
	});
    };

    var swiper = new Swiper('.swiper-container', {
      direction: 'horizontal',
      loop: true,
      updateOnWindowResize: true,
      speed: 400,
      effect: 'fade',
      preloadImages: false,
      lazy: {
	loadPrevNext: true,
	loadPrevNextAmount: 1,
      },
      autoplay: {
	    delay: {{ autoplay_delay }},
        disableOnInteraction: false,
      },
      pagination: {
        el: '.swiper-pagination',
        type: 'progressbar',
	clickable : false
      },
	on: {
		slideChange: onSlideChange,
		slideChangeTransitionEnd: onSlideChangeTransitionEnd

      },
    });
    document.querySelectorAll('video').forEach(video => {
	  video.addEventListener('ended', onVideoEnd);
	  video.addEventListener('error', onVideoEnd);
    });
    
  </script>
</body>

</html>

