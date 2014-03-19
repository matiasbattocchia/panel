require 'bundler/setup'
require 'active_record'
require 'csv'
require 'datamancer'

include Datamancer

bases = YAML.load_file('/home/matias/proyectos/panel/bases_de_datos.yml')

data =
extract from: bases['entidades'], table: 'Companias', exclude: true do
  
  field 'ds_com_compania', map: 'Denominacion',
    strip: true, reject_if: :null

  field 'ds_com_cuit', map: 'CUIT',
    strip: true, empty_default: '00000000000'
  
  field 'ds_com_direccion', map: 'Direccion_DL',
    strip: true, empty_default: 'SIN REGISTRAR'
  
  field 'ds_com_codigo_postal', map: 'Codigo_Postal',
    strip: true, empty_default: '00000000'
  
  field 'ds_com_telefono', map: 'Telefonos_DL',
    strip: true, empty_default: 'SIN REGISTRAR'
  
  field 'ds_com_fax', map: 'Fax_DL',
    strip: true, empty_default: 'SIN REGISTRAR'
  
  field 'ds_com_email', map: 'Email_DL',
    strip: true, empty_default: 'SIN REGISTRAR'
  
  field 'ds_com_web', map: 'Web_DL',
    strip: true, empty_default: 'SIN REGISTRAR'
  
  field 'ds_com_denominacion_corta', map: 'DenominacionCorta',
    strip: true, empty_default: 'SIN REGISTRAR'
  
  field 'ds_com_localidad', map: 'Localidad_DL',
    strip: true, empty_default: 'SIN REGISTRAR'
  
  field 'id_com_compania', map: 'CiaId',
    type: Integer, reject_if: 9999
  
  field 'id_com_cierre_ejercicio', map: 'Cierre_Balance',
    type: Integer, default: 0
  
  field 'id_com_reaseguradora', map: 'Reaseguradora',
    type: Integer, default: 0
  
  field 'id_geo_pais', map: 'Pais_ID',
    type: Integer, default: 0
  
  field 'id_geo_provincia', map: 'Provincia_DL_ID',
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

códigos = {
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

class Array
  
  def where criteria
    self.select do |row|
      result = true

      criteria.each do |field, value|
        unless row[field] == value
          result = false
          break
        end
      end

      result
    end
  end

end

países =
extract from: bases['panel'], table: 'lk_geo_pais'

data =
transform data do
  field 'ds_com_telefono', :slice, 0...70
  field 'ds_com_fax', :slice, 0...70
  field 'ds_com_email', :slice, 0...70
  field 'ds_com_web', :slice, 0...70
  field 'ds_com_denominacion_corta', :slice, 0...70
  field 'ds_com_localidad', :slice, 0...70
  field 'ds_com_direccion', :slice, 0...140
  field 'ds_com_compania', :slice, 0...140
  field 'ds_com_cuit', :slice, 0...11
  field 'ds_com_codigo_postal', :slice, 0...8

  field 'id_com_reaseguradora', id_com_actividad1 == 8 ||
                                id_com_actividad1 == 15 ? 'Sí' : 'No'

  field 'ds_com_cuit',
    '00000000000' if ds_com_cuit =~ /^(1*|4*)$/

  field 'id_geo_pais',
    países.where(id_geo_numero_pais: códigos[id_geo_pais]).first[:id_geo_pais]

  field 'id_geo_provincia',
    24 if id_geo_provincia == 26

  field 'id_com_grupo_compania',
    53 if id_com_grupo_compania == 0

  new_field 'id_com_segmentacion', 1
end

load data, to: bases['panel'], table: 'LK_COM_COMPANIA', append: false
