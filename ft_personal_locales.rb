require 'bundler/setup'
require 'datamancer'
require 'active_record'
require 'csv'

include Datamancer

bases = YAML.load_file('/home/matias/proyectos/panel/bases_de_datos.yml')

datos =
extract from: '/home/matias/proyectos/panel/datos/personal_locales_2006-2012.csv' do
  field 'id_com_compania', map: 'compania',
    type: Integer
  field 'id_com_provincia', map: 'provincia',
    type: Integer
  field 'id_tie_anio', map: 'periodo',
    type: Integer
  field 'id_com_tipo_sucursal', map: 'tipo local',
    type: Integer
  field 'i_loc_cant_locales', map: 'locales',
    type: Integer
  field 'i_per_cant_personal', map: 'empleados',
    type: Integer
end

mapa_provincias =
{10 =>  1,
 17 =>  2,
  9 =>  3,
  3 =>  4,
  6 =>  5,
 24 =>  6,
 22 =>  7,
 14 =>  8,
 12 =>  9,
 21 => 10,
  5 => 11,
 18 => 12,
  8 => 13,
  4 => 14,
 13 => 15,
 19 => 16,
  2 => 17,
 15 => 18,
 16 => 19,
  7 => 20,
 20 => 21,
 11 => 22,
 23 => 23,
  1 => 24}

datos =
transform datos do
  field 'id_com_provincia', mapa_provincias[id_com_provincia]
end

load datos, to: bases['panel'], table: 'ft_personal_locales', append: false
