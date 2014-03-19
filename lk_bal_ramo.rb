require 'bundler/setup'
require 'datamancer'
require 'active_record'

include Datamancer

bases = YAML.load_file('/home/matias/proyectos/panel/bases_de_datos.yml')

aperturas = [
{id_bal_agrup_ramos: 0,
 ds_bal_agrup_ramos: 'No aplica',
 cd_bal_agrup_ramos: '0'},

{id_bal_agrup_ramos: 1,
 ds_bal_agrup_ramos: 'Seguros de Daños Patrimoniales',
 cd_bal_agrup_ramos: '1'},

{id_bal_agrup_ramos: 2,
 ds_bal_agrup_ramos: 'Seguros de Personas',
 cd_bal_agrup_ramos: '2'},

{id_bal_agrup_ramos: 3,
 ds_bal_agrup_ramos: 'Sección Administración',
 cd_bal_agrup_ramos: '3'},
]

ramos =
extract from: bases['sinensup'], table: 'RAMOS', exclude: true do
  field 'id_bal_ramo', map: 'ID', reject_if: ['1', '17']
  field 'id_bal_agrup_ramos', map: 'apertura_ramo'
  field 'cd_bal_ramo', map: 'codigo_ramo'
  field 'ds_bal_ramo', map: 'descripcion'
end

ramos << {id_bal_ramo: 0, id_bal_agrup_ramos: 0, cd_bal_ramo: '000', ds_bal_ramo: 'No aplica'}

subramos =
extract from: bases['sinensup'], table: 'SUBRAMOS', exclude: true do
  field 'id_bal_subramo', map: 'ID'
  field 'cd_bal_subramo', map: 'codigo_subramo'
  field 'ds_bal_subramo', map: 'descripcion'
  field 'ds_bal_subramo_desccorta', map: 'descripcion_corta'
  field 'id_bal_ramo', map: 'ID_ramo'
end

subramos =
transform subramos do
  new_field 'id_bal_agrup_ramos', ramos.select { |ramo|
                                                 ramo[:id_bal_ramo] == id_bal_ramo
                                               }.first[:id_bal_agrup_ramos]
end

subramos << {id_bal_subramo: 0, cd_bal_subramo: '00', ds_bal_subramo: 'No aplica', ds_bal_subramo_desccorta: 'No aplica', id_bal_ramo: 0}

load aperturas, to: bases['panel'], table: 'lk_bal_agrup_ramos', append: false
load ramos, to: bases['panel'], table: 'lk_bal_ramo', append: false
load subramos, to: bases['panel'], table: 'lk_bal_subramo', append: false
