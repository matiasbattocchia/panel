require 'bundler/setup'
require 'datamancer'
require 'active_record'

include Datamancer

bases = YAML.load_file('bases_de_datos.yml')

cronogramas =
extract from: bases['sinensup'], table: 'CRONOGRAMAS', exclude: true do
  field 'id_tie_trimestre', map: 'periodo'
  field 'tipo_entrega', reject_unless: 'Trimestral'
  field 'id_cron_cronograma', map: 'ID'
end

entregas =
extract from: bases['sinensup'], table: 'ENTREGAS', exclude: true do
  field 'id_com_compania', map: 'ID_compania', type: Integer
  field 'id_cron_cronograma', map: 'ID_cronograma'
  field 'id_bal_balance', map: 'ID_ultima_entrega', reject_if: nil
end

polizas =
extract from: bases['sinensup'], table: 'PROD12', exclude: true do
  field 'anuladas', map: 'anul_rescin_salidas'
  field 'emitidas', map: 'emitidas_renovadas'
  field 'vencidas', map: 'vencidas_durante_trimestre'
  field 'vigentes', map: 'vigentes_fin_trimestre_ant'
  field 'poliza_certificado', reject_unless: 'P'
  field 'id_bal_balance', map: 'ID_plan_cuentas_unificado'
  field 'id_bal_subramo', map: 'ID_subramo', type: Integer
end

entregas =
transform entregas, join: cronogramas, on: 'id_cron_cronograma' do
  del_field 'id_cron_cronograma'
  del_field 'tipo_entrega'
end

polizas =
transform polizas, join: entregas, on: 'id_bal_balance' do
  del_field 'id_bal_balance'
  del_field 'poliza_certificado'
  del_field 'anuladas'
  del_field 'emitidas'
  del_field 'vencidas'
  del_field 'vigentes'
  new_field 'i_cant_polizas', vigentes + emitidas - anuladas - vencidas
  field     'id_tie_trimestre', id_tie_trimestre.gsub('-', '0').to_i
end

load polizas, to: bases['panel'], table: 'ft_polizas', append: false
