@echo off

:: Seteamos ambiente para usar variables retrasadas.
SETLOCAL ENABLEDELAYEDEXPANSION

:: Obtenemos fecha y hora actual.
call :ObtieneFecha

:: Obtener caracter ESC a variable.
for /F %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"

:: Obtener la fecha epoch de inicio de ejecucion.
set /a ini=%Epoch%

:: Inicio de ejecucion.
echo [%YYYYMMDD_HH24_MI_SS%][BTC-USDT] ... Start.

:: Consultar a Coinbase los precios del libro de ordenes.
:GetPrice
for /F "tokens=1,4 delims=," %%a in ('curl -s https://api.exchange.coinbase.com/products/BTC-USDT/book?level^=1') do (
	:: Obtener precio ASK y BID.
	set ask_c=%%b
	set bid_c=%%a
	:: Limpiar comillas dobles.
	set "ask_c=!ask_c:"=!"
	set "bid_c=!bid_c:"=!"

	:: Limpiar palabras y caracteres adicionales.
	for %%k in ([ ] : { asks bids) do (
		set "ask_c=!ask_c:%%k=!"
		set "bid_c=!bid_c:%%k=!"
	)
)

:: Formatear longitud decimal a 2 digitos.
call :round !ask_c! 2 ask_c
call :round !bid_c! 2 bid_c

:: Actualizar fichero de precios.
call :UpdatePriceInFile

:: Imprimir en pantalla.
call :ObtieneFecha
echo !ESC![90m[!YYYYMMDD_HH24_MI_SS!][BTC-USDT]!ESC![0m ... Coinbase . !ESC![91m!ask_c!!ESC![0m !ESC![92m!bid_c!!ESC![0m

:: Guardar al portapapeles.
rem echo !YYYYMMDD_HH24_MI_SS![BTC-USDT] ... ask:!ask_c! bid:!bid_c!| clip

:: Se da opcion al usuario que presione una tecla A o B para evitar la espera de los 5 segundos o detener el monitoreo.
:: por defecto es la opcion A de obtener el precio una vez que termine el periodo de espera de 5 segundos.
choice /C AB /N /T 5 /D A >Nul
if !errorlevel! equ 1 (
	rem echo Has presionado A.
	goto :GetPrice
) else if !errorlevel! equ 2 (
	rem echo Has presionado B.
	goto :Fin
)

:: Salimos reportando ejecución Ok.
:Fin
call :ObtieneFecha
set /a fin=%Epoch%
set /a dif=!fin!-!ini!
echo [!YYYYMMDD_HH24_MI_SS!][BTC-USDT] ... End ... Elapsed: !dif!s.

Exit 0

:: Obtiene en variable las fecha y hora actual en diferentes formatos.
:ObtieneFecha
	for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
	set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
	set "HH24=%dt:~8,2%" & set "MIN=%dt:~10,2%" & set "SEG=%dt:~12,2%" & set "CENT=%dt:~15,2%" & set "MIL=%dt:~15,3%"

	set YYYYMM=%YYYY%%MM%
	set YYYYMMDD=%YYYY%%MM%%DD%
	set YYYYMMDDHH24MISS=%YYYY%%MM%%DD%%HH24%%MIN%%SEG%
	set YYYYMMDDHH24MISSCE=%YYYY%%MM%%DD%%HH24%%MIN%%SEG%%CENT%
	set YYYYMMDDHH24MISSML=%YYYY%%MM%%DD%%HH24%%MIN%%SEG%%MIL%
	set YYYYMMDD_HH24_MI_SS=%YYYY%-%MM%-%DD% %HH24%:%MIN%:%SEG%
	
	for /f %%e in ('gawk "BEGIN {print systime()}"') do set "Epoch=%%e"
goto :eof

:: Funcion agrega cero a la derecha del punto decimal segun longitud solicitada
:: recibe tres parametros:
:: param1 --numero a procesar.
:: param2 --longitud.
:: param3 --nombre de la variable donde se desea guardar el resultado.
:round 
	rem Define la variable con el número original 
	set numero=%~1%
	set lon=%~2%
	set var=%~3%

	rem Asegurarse de que el número tenga la longitud deseada de dígitos decimales 
	for /f "tokens=1,2 delims=." %%a in ("%numero%") do (
		set entero=%%a
		set decimal=%%b
	)
	if "%decimal%"=="" set "decimal=00"
	for /L %%i in (1,1,%lon%) do (
		if "!decimal:~%%i,1!"=="" set "decimal=!decimal!0"
	)
	set "decimal=!decimal:~0,%lon%!"
	set "%var%=%entero%.%decimal%"
goto :eof

:: Actualiza el precio ASK y BID en fichero de precio.
:UpdatePriceInFile
	set fchPrice=Price.dat
	echo ask_c;!ask_c! >"%fchPrice%"
	echo bid_c;!bid_c! >>"%fchPrice%"
goto :eof