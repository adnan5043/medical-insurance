class TransactionDataController < ApplicationController
  before_action :set_transaction_data, only: [:edit, :update, :destroy]

  def index
    @transaction_data = TransactionData.new
    @transaction_dataa = TransactionData.where.not(received_payment: nil)

    if params[:matching_record]
      @transaction_dataa = [TransactionData.find(params[:matching_record])]
    end
  end

  def new
  end

  def create
    @transaction_data = TransactionData.find_by(activity_id: transaction_data_params[:activity_id],
                                                 data_type: transaction_data_params[:data_type])

    if @transaction_data
      flash[:notice] = 'Transaction record found. Please update the record.'
      redirect_to transaction_data_path(matching_record: @transaction_data.id) 
    else
      flash[:alert] = 'No matching record found'
      redirect_to transaction_data_path
    end
  end

  def edit
  end

  def update
    if @transaction_data.update(transaction_data_params)
      redirect_to transaction_data_path, notice: 'Transaction data updated successfully'
    else
      render :edit
    end
  end

  def destroy
    if @transaction_data.update(received_payment: nil)
      redirect_to transaction_data_path, notice: 'Payment column cleared successfully'
    else
      redirect_to transaction_data_path, alert: 'Failed to clear payment column'
    end
  end

  private

  def set_transaction_data
    @transaction_data = TransactionData.find(params[:id])
  end

  def transaction_data_params
    params.require(:transaction_data).permit(:receiver_id, :activity_id, :data_type, :received_payment)
  end
end
