$(function(){

  if ($('#title').text() == '運航管理画面') {
    id = setInterval(function() {
      location.reload();
    }, 300000);
  }

  $('#title').click(function() {
    clearInterval(id);
  })

});
