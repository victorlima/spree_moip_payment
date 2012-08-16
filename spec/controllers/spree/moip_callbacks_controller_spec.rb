require 'spec_helper'

describe Spree::MoipCallbacksController do
  describe "POST nasp" do
    let!(:moip) { FactoryGirl.create(:moip_payment_method) }
    let!(:order) { FactoryGirl.create(:moip_order, number: "R033822677", total: 13.99, state: "delivery", user: FactoryGirl.create(:user, email: "johndoe@example.com")) }
    let!(:payment) { FactoryGirl.create(:moip_payment, order: order) }
    let!(:item) { FactoryGirl.create(:line_item, :order => order) }

    context "concluido" do
      context "com valor correto" do
        it {
          expect {
            post :nasp, post_nasp_params.merge!(status_pagamento: "4", id_transacao: order.number, valor: order.total)
          }.to change{order.reload.payment.state}.from("pending").to("completed")
        }
      end
      context "com valor incorreto" do
        it {
          expect {
            post :nasp, post_nasp_params.merge!(status_pagamento: "4", id_transacao: order.number, valor: "199")
          }.to change{order.reload.payment.state}.from("pending").to("pending")
        }
      end
    end
    context "cancelado" do
      it {
        expect {
          post :nasp, post_nasp_params.merge!(status_pagamento: "5", id_transacao: order.number, valor: order.total)
        }.to change{order.reload.payment.state}.from("pending").to("void")
      }
    end
    context "estornado" do
      it {
        expect {
          post :nasp, post_nasp_params.merge!(status_pagamento: "7", id_transacao: order.number, valor: order.total)
        }.to change{order.reload.payment.state}.from("pending").to("void")
      }
    end
  end
end