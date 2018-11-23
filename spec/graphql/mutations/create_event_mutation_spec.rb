Rspec.describe ZooStatsSchema do
  let(:context) { {} }
  let(:variables) { {"event_payload": event_payload} }
  let(:mutation_string) do
    "mutation ($event_payload: String!){
      createEvent(eventPayload: $event_payload){
        errors
      }
    }"
  end
  let(:result) do
    ZooStatsSchema.execute(
      mutation_string,
      context: context,
      variables: variables
    )
  end
  let(:prepared_payload_1) { nil }
  let(:prepared_payload_2) { nil }
    
  before do
    transformer_stub = double("transformer_stub", :transform => prepared_payload)
    transformer_stub_1 = double("transformer_stub", :transform => prepared_payload_1)
    transformer_stub_2 = double("transformer_stub", :transform => prepared_payload_2)
    event_payload_hash = JSON.parse(event_payload)[0] if not event_payload.empty?
    allow(Transformers::PanoptesClassification).to receive(:new).with(event_payload_hash).and_return(transformer_stub, transformer_stub_1, transformer_stub_2)
  end

  describe 'createEvent' do
    context 'when there is an empty payload' do
      let(:event_payload) { "" }
      let(:prepared_payload) { nil }
      it 'throws an Argument error' do
        errors = result["data"]["createEvent"]["errors"]
        message = eval(errors[0])["message"]
        expect(message).to start_with("Argument")
      end

      it 'does not add anything to the database' do
        expect { result }.not_to change { Event.count }
      end
    end

    context 'when there is a single event payload' do
      let(:event_payload) { JSON.dump([{"test" => "hash"}]) }
      let(:prepared_payload) do 
        {
          event_id:            123,
          event_type:          "classification",
          event_source:        "Panoptes",
          event_time:          DateTime.parse('2018-11-06 05:45:09'),
          project_id:          456,
          workflow_id:         789,
          user_id:             1011,
          data:                {"metadata" => 'test'},
          session_time:        5.0
        }
      end
      it 'adds the correct Event into the database' do
        expect { result }.to change { Event.count }.by 1

        stored_attributes = Event.last.attributes.to_options
        prepared_payload.each do |key, value|
          expect(value).to eq(stored_attributes[key])
        end
      end
    end

    context 'when there is an erroring event' do
      let(:event_payload) { JSON.dump([{"test" => "hash"},{"test" => "hash"},{"test" => "hash"}]) }
      let(:prepared_payload) do 
        {
          event_id:            123,
          event_type:          "classification",
          event_source:        "Panoptes",
          event_time:          DateTime.parse('2018-11-06 05:45:09'),
          project_id:          456,
          workflow_id:         789,
          user_id:             1011,
          data:                {"metadata" => 'test'},
          session_time:        5.0
        }
      end
      let(:prepared_payload_1) do 
        prepared_payload.merge({
          event_id:            456
        })
      end
      let(:prepared_payload_2) do 
        prepared_payload.merge({
          event_id:            789,
          event_source:        nil
        })
      end
      it 'reverts the batch and returns the error' do
        expect { result }.not_to change { Event.count }
        expect(result["errors"][0]["message"]).to eq("Validation failed: Event source can't be blank")
      end
    end

    context 'when there is a repeated event' do
      let(:event_payload) { JSON.dump([{"test" => "hash"},{"test" => "hash"}]) }
      let(:prepared_payload) do 
        {
          event_id:            123,
          event_type:          "classification",
          event_source:        "Panoptes",
          event_time:          DateTime.parse('2018-11-06 05:45:09'),
          project_id:          456,
          workflow_id:         789,
          user_id:             1011,
          data:                {"metadata" => 'test'},
          session_time:        5.0
        }
      end
      let(:prepared_payload_1) do 
        prepared_payload
      end
      it 'add only one row to the database without errors' do
        expect { result }.to change { Event.count }.by 1
        errors = result["data"]["createEvent"]["errors"][0]
        expect(errors).to be_nil
      end
    end
  end
end
