set OS=%1
set SOURCE_DIR=%2
set BUILD_DIR=%3
set DATA_DIR=%4

winpty docker run ^
  --name mantid_development_%OS% ^
  --rm ^
  --interactive ^
  --tty ^
  --env PUID='id -u' ^
  --env PGID='id -g' ^
  --shm-size=512m ^
  --volume %SOURCE_DIR%:/mantid_src ^
  --volume %BUILD_DIR%:/mantid_build ^
  --volume %DATA_DIR%:/mantid_data ^
  mantidproject/mantid-development-%OS%:latest
