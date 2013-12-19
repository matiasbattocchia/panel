require 'bundler/setup'
require 'datamancer'
require 'active_record'
require 'csv'

include Datamancer

bases = YAML.load_file('/home/matias/proyectos/panel/bases_de_datos.yml')

data =
extract from: bases['entidades'], table: 'Companias', exclude: true do
  field 'ds_com_compania', map: 'Denominacion',
    strip: true, reject_if: :null
  field 'ds_com_cuit', map: 'CUIT',
    strip: true, default: 'SIN REGISTRAR'
  field 'ds_com_direccion', map: 'Direccion_DL',
    strip: true, default: 'SIN REGISTRAR'
  field 'id_com_codigo_postal', map: 'Codigo_Postal',
    strip: true, default: 'SIN REGIST'
  field 'ds_com_telefono', map: 'Telefonos_DL',
    strip: true, default: 'SIN REGISTRAR'
  field 'ds_com_fax', map: 'Fax_DL',
    strip: true, default: 'SIN REGISTRAR'
  field 'ds_com_email', map: 'Email_DL',
    strip: true, default: 'SIN REGISTRAR'
  field 'ds_com_web', map: 'Web_DL',
    strip: true, default: 'SIN REGISTRAR'
  field 'ds_com_denominacion_corta', map: 'DenominacionCorta',
    strip: true, default: 'SIN REGISTRAR'
  field 'id_com_cia_id', map: 'CiaId',
    strip: true, reject_if: '9999' #TODO: or :null
  field 'id_com_fecha_balance', map: 'Cierre_Balance',
    strip: true, default: 'SIN REGISTRAR'
  field 'id_com_reseaguradora', map: 'Reaseguradora',
    strip: true, default: 'SIN REGISTRAR'
  field 'id_com_localidad', map: 'Localidad_DL',
    strip: true, default: 'SIN REGISTRAR'
  field 'id_com_pais', map: 'Pais_ID',
    type: Integer, default: 0
  field 'id_com_provincia', map: 'Provincia_DL_ID',
    type: Integer, default: 25
  field 'id_com_grupo_compania', map: 'Grupo_ID',
    type: Integer, default: 0
  field 'id_com_estado_compania', map: 'Estado_ID',
    type: Integer, default: 0
  field 'id_com_actividad2', map: 'Actividad2_ID',
    type: Integer, default: 0
  field 'id_com_actividad1', map: 'Actividad1_ID',
    type: Integer, default: 0
  field 'id_com_tipo_social', map: 'Tipo_Social_ID',
    type: Integer, default: 0
end

países = {
  1 => 276,
  2 => 36,
  3 => 52,
  4 => 60,
  5 => 76,
  6 => 724,
  7 => 840,
  8 => 250,
  9 => 528,
  10 => 826,
  11 => 756,
  12 => 32,
  13 => 0,
  14 => 380,
  15 => 862,
  16 => 858,
  17 => 152,
  18 => 214,
  19 => 620,
  20 => 616,
  21 => 600,
  22 => 591,
  23 => 554,
  24 => 558,
  25 => 826,
  26 => 218,
  27 => 170,
  28 => 124,
  29 => 40,
  30 => 376,
  31 => 484,
  32 => 136,
  33 => 44,
  34 => 92,
  35 => 850,
  36 => 604,
  37 => 392,
  38 => 208,
  39 => 826,
  40 => 372
}

data =
transform data do
  new_field 'id_com_compania', id_com_cia_id.to_i
  field 'ds_com_telefono', :slice, 0...20
  field 'ds_com_fax', :slice, 0...20
  field 'id_com_fecha_balance', '2013-01-01 00:00:00'
  field 'ds_com_cuit',
    'SIN REGISTRAR' if ds_com_cuit =~ /^(1*|4*)$/
  field 'id_com_pais',
    países[id_com_pais]
  field 'id_com_provincia',
    24 if id_com_provincia == 26
  field 'id_com_grupo_compania',
    53 if id_com_grupo_compania == 0
  field 'id_com_reseaguradora',
    id_com_reseaguradora == '1' ? 'Sí' : 'No'
  new_field 'id_com_segmentacion', 1
  new_field 'cd_com_compania', 'vacío'
end

load data, to: bases['panel'], table: 'LK_COM_COMPANIA', append: false
