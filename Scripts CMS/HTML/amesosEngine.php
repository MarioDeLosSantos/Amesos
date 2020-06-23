<html>

<div>
        <div id="boxParent"></div>
</div>

    <div>

        <script>
        async function controller()
        {
            var buttonController= <?php buttonController();?> //call the php add function

            if(buttonController == 1)
                window.location = window.location.href.split("?")[0];
        }
        
        controller();
        </script>


        <script>
        async function readTextFile(file, callback) {  

            <?php updateData(); ?>

            
            var len = 0;

            var rawFile = new XMLHttpRequest();
        
            rawFile.overrideMimeType("application/json");
            rawFile.open("GET", file, true);

            
            // Para que no lo almacene en caché y lea el archivo en busca de cambios constantemente
            rawFile.setRequestHeader('Cache-Control', 'no-cache');
            
            rawFile.onreadystatechange = function() {
                if (rawFile.readyState === 4 && rawFile.status == "200") {

                    var data = JSON.parse(rawFile.responseText);
                    len = callback(data, len);

                    console.log("VAl: " + len);
                }
            }
            
            rawFile.send(null);
        }

            readTextFile("/amesos/scripts/info/datos.json", function(data, len){

                // Para probar, cogemos los datos del Centro 1 sin más  
                var new_len = Object.keys(data.Centres[0].Servers).length;

                for (var i = len; i < new_len; i++) {
                    var row = document.createElement('div');
                    row.className = "row";
                
                    var box = document.createElement('div');
                    box.className = "box";
                    
                    box.textContent += "CPU: " + data.Centres[0].Servers[i].CPU + " %" + "\r\n";
                    box.textContent += "Memory: " + data.Centres[0].Servers[i].Mem + " %" + "\r\n";
                    box.textContent += "Time up: " + data.Centres[0].Servers[i].TimeUp + " mins" + "\r\n";
                    box.textContent += "Cost: " + data.Centres[0].Servers[i].Cost + " $"+ "\r\n";
                 
                    row.appendChild(box);
                                
                    document.getElementById('boxParent').appendChild(row);
                }

                return new_len;
        });
        </script>
    </div>
</html>




<?php
function buttonController()
{
    if ($_GET['info']) {
 
       $salida=shell_exec('./scripts/info/jsonInformativo.sh');
       echo 1;
       return;
      }
      elseif ($_GET['encender']) {
       $salida=shell_exec('./scripts/info/lanzarServidor.sh Centro1');
       echo 1;
       return;
      }
      elseif($_GET['apagar']) {
       $salida=shell_exec('./scripts/info/apagarServidor.sh Centro1');
       echo 1;
       return;
      }

    echo 0;    
    return; 
}
?>

<?php
function updateData()
{
    shell_exec('./scripts/info/datos.sh Centro1');
    shell_exec('./scripts/info/actualizarTiempoYCoste.sh Centro1');
}
?>