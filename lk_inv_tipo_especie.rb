require 'bundler/setup'
require 'datamancer'
require 'active_record'

include Datamancer

bases = YAML.load_file('/home/matias/proyectos/panel/bases_de_datos.yml')

subtipos =
extract(from: bases['sinensup'], table: 'INV_SUBTIPOS_ESPECIE', exclude: true) do
  field 'ds_inv_subtipo_especie', map: 'descripcion',
    strip: true
  field 'id_inv_subtipo_especie', map: 'ID',
    type: Integer
  field 'id_inv_tipo_especie', map: 'tipo_especie',
    strip: true
end

mapa_tipos = {
  'ACCION' => 'AC',
  'FONDO_COMUN' => 'FC',
  'FIDEICOMISO' => 'FF',
  'OBLIGACION_NEGOCIABLE' => 'ON',
  'OPCION' => 'OP',
  'TITULO_PUBLICO' => 'TP'
}

subtipos =
transform subtipos do
  field 'id_inv_tipo_especie', mapa_tipos[id_inv_tipo_especie]
  field 'ds_inv_subtipo_especie', ds_inv_subtipo_especie.gsub('FF - ', '').gsub('´', '')
end

tipos = [
  {id_inv_tipo_especie: 'AC', ds_inv_tipo_especie: 'Acción'},
  {id_inv_tipo_especie: 'FC', ds_inv_tipo_especie: 'Fondo Común'},
  {id_inv_tipo_especie: 'FF', ds_inv_tipo_especie: 'Fideicomiso'},
  {id_inv_tipo_especie: 'ON', ds_inv_tipo_especie: 'Obligación Negociable'},
  {id_inv_tipo_especie: 'OP', ds_inv_tipo_especie: 'Opción'},
  {id_inv_tipo_especie: 'TP', ds_inv_tipo_especie: 'Título Público'}
]

load tipos, to: bases['panel'], table: 'lk_inv_tipo_especie', append: false
load subtipos, to: bases['panel'], table: 'lk_inv_subtipo_especie', append: false
