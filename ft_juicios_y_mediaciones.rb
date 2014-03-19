require 'bundler/setup'
require 'datamancer'
require 'active_record'
require 'csv'

include Datamancer

bases = YAML.load_file('/home/matias/proyectos/panel/bases_de_datos.yml')

juicios =
extract from: bases['sinensup'], table: 'JUICIOS_MEDIACIONES_ESTUDIOS', exclude: true do
  field 'cantidad', type: Integer
  # field 'monto', type: Integer
  field 'clase', map: 'juicio_mediacion', strip: true
  field 'tipo', map: 'ID_tipo_juicio_mediacion', type: Integer # 6 => Mediación que va a Juicio
  field 'id_bal_balance', map: 'ID_plan_cuentas_unificado'
  field 'id_bal_subramo', map: 'ID_subramo', type: Integer
end

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

entregas =
transform entregas, join: cronogramas, on: 'id_cron_cronograma' do
  del_field 'id_cron_cronograma'
  del_field 'tipo_entrega'
  field     'id_tie_trimestre', id_tie_trimestre.gsub('-', '0').to_i
end

siniestros =
extract from: bases['sinensup'], table: 'SIN1', exclude: true do
  field 'i_jui_cant_siniestros_denunciados', map: 'cant_siniestros_denunciados'
  field 'id_bal_balance', map: 'ID_plan_cuentas_unificado'
  field 'id_bal_subramo', map: 'ID_subramo', type: Integer
end

juicios =
transform juicios, join: entregas, on: 'id_bal_balance' do
  new_field 'i_jui_cant_juicios', clase == 'JUICIOS' ? cantidad : 0
  # new_field 'i_jui_imp_juicios', clase == 'JUICIOS' ? monto : 0
  new_field 'i_jui_cant_mediaciones', clase == 'MEDIACIONES' ? cantidad : 0
  # new_field 'i_jui_imp_mediaciones', clase == 'MEDIACIONES' ? monto : 0
  new_field 'i_jui_cant_mediaciones_a_juicio', clase == 'MEDIACIONES' && tipo == 6 ? cantidad : 0
  del_field 'cantidad'
  # del_field 'monto'
  del_field 'clase'
  del_field 'tipo'
end

siniestros =
transform siniestros, join: entregas, on: 'id_bal_balance' do
  del_field 'id_bal_balance'
end

todo =
agreggate (transform juicios, add: siniestros) do
  dim 'id_com_compania'
  dim 'id_tie_trimestre'
  dim 'id_bal_subramo'
  fact 'i_jui_cant_juicios'
  # fact 'i_jui_imp_juicios'
  fact 'i_jui_cant_mediaciones'
  # fact 'i_jui_imp_mediaciones'
  fact 'i_jui_cant_mediaciones_a_juicio'
  fact 'i_jui_cant_siniestros_denunciados'
end

load todo, to: bases['panel'], table: 'ft_juicios_y_mediaciones', append: false
