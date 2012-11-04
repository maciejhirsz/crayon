
canvas = new rippl.Canvas({
  width: 269,
  height: 120
});

document.getElementById('logo').appendChild(canvas.getDocumentElement());

rippl.assets.preload('img/rippl.png', function(){

  timer = new rippl.Timer({ fps: 60 });
  timer.bind(canvas);

  var logo = canvas.createSprite({
    src: 'img/rippl.png',
    alpha: 0,
    x: 0,
    y: 0,
    width: 269,
    height: 120,
    anchorX: 0,
    anchorY: 0
  });

  var mask = canvas.createShape({
    alpha: 1,
    color: '#000',
    composition: 'source-atop',
    x: 0,
    y: 0,
    width: 269,
    height: 120,
    anchorX: 0,
    anchorY: 0
  });

  var bling = canvas.createShape({
    alpha: 0.66,
    color: '#fff',
    composition: 'source-atop',
    x: -40,
    y: 60,
    rotation: Math.PI / 10,
    width: 20,
    height: 150
  });

  logo.transform({
    duration: 500,
    transition: 'easeIn',
    delay: 300,
    to: {
      alpha: 1
    }
  });

  mask.transform({
    duration: 500,
    delay: 1000,
    transition: 'easeOut',
    to: {
      alpha: 0
    }
  });

  bling.transform({
    duration: 600,
    delay: 1100,
    transition: 'easeInOut',
    from: {
      x: -40
    },
    to: {
      x: 300
    }
  })

});