require 'bundler/setup'
require 'datamancer'
require 'active_record'

include Datamancer

bases = YAML.load_file('/home/matias/proyectos/panel/bases_de_datos.yml')

datos =
extract from: bases['entidades'], table: 'Directorio', exclude: true do

# lk_dir_funcion_directorio

  field 'ds_dir_funcion_directorio', map: 'Funcion_DL',
    strip: true, empty_default: 'SIN REGISTRAR'

# lk_dir_persona_directorio

  field 'documento', map: 'Numero_DU',
    type: Integer, reject_if: nil
  field 'ds_dir_persona_directorio', map: 'Nombre_DL',
    strip: true, empty_default: 'SIN REGISTRAR'
  field 'ds_dir_nacionalidad', map: 'Nacionalidad_DL',
    strip: true, empty_default: 'SIN REGISTRAR'
  field 'ds_dir_cuit', map: 'CUIT',
    strip: true, empty_default: 'SIN REGISTRAR'
  field('ds_dir_fecha_nacimiento', map: 'Fecha_Nacimiento') { |f| Time.new(f).strftime('%F') }

# ft_directorio

  field('id_dir_fecha_desde', map: 'Fecha_Desde') { |f| Time.new(f).strftime('%F') }
  field('id_dir_fecha_hasta', map: 'Fecha_Hasta') { |f| Time.new(f).strftime('%F') }
  field 'id_com_compania', map: 'CiaId',
    type: Integer, reject_if: nil
end

# lk_dir_persona_directorio

personas =
transform datos, unique: 'documento', exclude: true do
  new_field 'id_dir_persona_directorio', row_number
  field 'documento'
  field 'ds_dir_persona_directorio'
  field 'ds_dir_nacionalidad'
  field 'ds_dir_cuit'
  field 'ds_dir_fecha_nacimiento'
  new_field 'cd_dir_persona_directorio', 'vacío'
end

# lk_dir_funcion_directorio

funciones =
transform datos, unique: 'ds_dir_funcion_directorio', exclude: true do
  field 'ds_dir_funcion_directorio'
  new_field 'id_dir_funcion_directorio', row_number
  new_field 'cd_dir_funcion_directorio', 'vacío'
end

# ft_directorio

mapa_funciones = Hash.new

funciones.each do |funcion|
  mapa_funciones[funcion[:ds_dir_funcion_directorio]] = funcion[:id_dir_funcion_directorio]
end

mapa_personas = Hash.new

personas.each do |persona|
  mapa_personas[persona[:documento]] = persona[:id_dir_persona_directorio]
end

directores =
transform datos, exclude: true do
  field 'id_dir_fecha_desde'
  field 'id_dir_fecha_hasta'
  del_field 'documento'
  new_field 'id_dir_persona_directorio', mapa_personas[documento]
  field 'id_com_compania'
  new_field 'id_dir_funcion_directorio', mapa_funciones[ds_dir_funcion_directorio]
  new_field 'i_dir_cantidad', 1
end

personas =
transform personas do
  del_field 'documento'
end

load funciones, to: bases['panel'], table: 'lk_dir_funcion_directorio', append: false
load personas, to: bases['panel'], table: 'lk_dir_persona_directorio', append: false
load directores, to: bases['panel'], table: 'ft_directorio', append: false
