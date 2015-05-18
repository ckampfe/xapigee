defmodule Composer do
  def build([], doc), do: Enum.reverse doc

  def build([{'preflow', props}|rest], doc) do
    preflow = """
    <Preflow>
      <%= res %>
    </Preflow>
    """ |> EEx.eval_string [res: build(props, [])]

    build(rest, [preflow|doc])
  end

  def build([{'flows', flows}|rest], doc) do
    flow_props =
      flows
      |> Enum.flat_map(
        fn({flow_name, flow_desc}) ->
          [
          """
          <Flow name=<%= flow_name %>>
            <%= flow_desc_res %>
          </Flow>
          """ |> EEx.eval_string [
            flow_name: flow_name,
            flow_desc_res: build(flow_desc, [])]
          ]
        end
      )

    flows = """
    <Flows>
      <%= flow_props %>
    </Flows>
    """ |> EEx.eval_string [flow_props: flow_props]

    build(rest, [flows|doc])
  end

  def build([{'request', props}|rest], doc) do
    request = """
      <Request>
      <%= for item <- props do %>
        <Step><Name><%= item %></Name></Step>
      <% end %>
      </Request>
    """ |> EEx.eval_string [props: props]

    build(rest, [request|doc])
  end

  def build([{'response', :null}|rest], doc) do
    build(rest, ["  <Reponse />"|doc])
  end

  def build([{'response', props}|rest], doc) do
    response = """
    <Response>
    <%= for item <- props do %>
      <Step><Name><%= item %></Name></Step>
    <% end %>
    </Response>
    """ |> EEx.eval_string [props: props]

    build(rest, [response|doc])
  end

  def build([{'path', path}, {'verb', verb}|rest], doc) do
    match_condition = """
    <Condition>(proxy.pathsuffix MatchesPath "<%= path %>") and (request.verb = "<%= verb %>")</Condition>
    """
    |> EEx.eval_string [path: path, verb: verb]

    build(rest, [match_condition|doc])
  end

  def build([{'httpproxyconnection', props}|rest], doc) do
    httpproxyconnection = """
    <HTTPProxyConnection>
    <%= props %>
    </HTTPProxyConnection>
    """ |> EEx.eval_string [props: build(props, [])]

    build(rest, [httpproxyconnection|doc])
    # <BasePath>/ios/v2/rewards</BasePath>
    # <VirtualHost>secure</VirtualHost>
  end

  def build([{'basepath', basepath}|rest], doc) do
    base_path = """
      <BasePath><%= base_path %></BasePath>
      <VirtualHost>secure</VirtualHost>
    """ |> EEx.eval_string [base_path: basepath]

    build(rest, [base_path|doc])
  end

  def build([{'routerules', routerules}|rest], doc) do
    route_rule_props =
      routerules
      |> Enum.flat_map(
         fn({route_name, route_desc}) ->
           [
           """
           <RouteRule name=<%= route_name %>>
             <%= route_desc_res %>
           </RouteRule>
           """ |> EEx.eval_string [
             route_name: route_name,
             route_desc_res: build(route_desc, [])]
           ]
         end
      )

    build(rest, [route_rule_props|doc])
  end

  def build([{'faultrules', faultrules}|rest], doc) do
    fault_rule_props =
      faultrules
      |> Enum.flat_map(
         fn({fault_rule_name, [name, [{'name', condition}]]}) ->
           [
             """
             <FaultRule name=<%= fault_rule_name %>>
               <Step>
                 <Name>
                   <%= name %>
                 </Name>
               </Step>
               <Condition>fault.name = "<%= condition %>"</Condition>
             </FaultRule>

             """ |> EEx.eval_string [
               fault_rule_name: fault_rule_name,
               name: name,
               condition: condition
             ]
           ]
         end
      )

    build(rest, [fault_rule_props|doc])
  end
end
