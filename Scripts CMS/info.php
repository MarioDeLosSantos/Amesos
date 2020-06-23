

<?php
function update()
{
    shell_exec('./scripts/info/datos.sh Centro1');
    shell_exec('./scripts/info/actualizarTiempoYCoste.sh Centro1');
}


if(isset($_GET['function'])) {
  if($_GET['function'] == 'update') {
    update(); 
  }
}
?>
