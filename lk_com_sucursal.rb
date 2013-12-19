require 'bundler/setup'
require 'datamancer'
require 'active_record'

include Datamancer

bases = YAML.load_file('/home/matias/proyectos/panel/bases_de_datos.yml')

datos =
extract from: bases['entidades'], table: 'Sucursales', exclude: true do
  field 'SucID', type: Integer
  field 'Estado', reject_unless: 1
  field 'ds_com_sucursal', map: 'SucNombre',
    strip: true, empty_default: 'SIN REGISTRAR'
  field 'ds_com_localidad_suc', map: 'Localidad_DL',
    strip: true, empty_default: 'SIN REGISTRAR'
  field 'ds_com_direccion_suc', map: 'Direccion_DL',
    strip: true, empty_default: 'SIN REGISTRAR'
  field 'ds_com_cod_postal_suc', map: 'Codigo_Postal_DL',
    strip: true, empty_default: 'SIN REGIST'
  field 'id_com_provincia_suc', map: 'Provincia_ID',
    strip: true, reject_if: nil
  field 'ds_com_telefono_suc', map: 'Telefonos_DL',
    strip: true, empty_default: 'SIN REGISTRAR'
  field 'ds_com_fax_suc', map: 'Fax_DL',
    strip: true, empty_default: 'SIN REGISTRAR'
  field 'id_com_tipo_sucursal', map: 'Tipo',
    strip: true, reject_if: nil
  field 'id_com_compania', map: 'CiaId',
    strip: true, reject_if: nil, type: Integer
end

provincias = { 
'Jujuy' => 1,
'Salta' => 2,
'Formosa' => 3,
'Catamarca' => 4,
'Chaco' => 5,
'Tucumán' => 6,
'Santiago del Estero' => 7,
'Sgo. del Estero' => 7,
'Misiones' => 8,
'La Rioja' => 9,
'Santa Fe' => 10,
'Corrientes' => 11,
'San Juan' => 12,
'Entre Ríos' => 13,
'Entre Rios' => 13,
'Córdoba' => 14,
'Mendoza' => 15,
'San Luis' => 16,
'Buenos Aires' => 17,
'Neuquén' => 18,
'Río Negro' => 19,
'Chubut' => 20,
'Santa Cruz' => 21,
'La Pampa' => 22,
'Tierra del Fuego' => 23,
'Ciudad Autónoma de Buenos Aires' => 24,
'CABA' => 24,
'Capital Federal' => 24,
'SIN REGISTRAR' => 25}

datos =
transform datos do
  field 'id_com_provincia_suc', provincias[id_com_provincia_suc]
  field 'id_com_tipo_sucursal', case id_com_tipo_sucursal
                                when 'S' then 2
                                when 'A' then 3
                                end
  new_field 'cd_com_sucursal', 0 #'vacío'
  new_field 'id_com_sucursal', id_com_compania * 100 + sucid
  new_field 'id_com_gerente', id_com_compania * 100 + sucid
  del_field 'Estado'
  del_field 'SucID'
end

datos =
transform datos do
  field 'id_com_provincia_suc', if id_com_provincia_suc.is_a?(String) then 13 end
end

load datos, to: bases['panel'], table: 'lk_com_sucursal', append: false
