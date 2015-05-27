defmodule Xapigee.Composer do
  def build([], {doc, policies}), do: {Enum.reverse(doc), policies}

  def build([{'preflow', props}|rest], {doc, policies}) do

    {preflows, new_policies} = build(props, {[], []})

    preflow = """
    <Preflow>
      <%= preflows %>
    </Preflow>
    """ |> EEx.eval_string [preflows: preflows]

    build(rest, {[preflow|doc], new_policies ++ policies})
  end

  def build([{'flows', flows}|rest], {doc, policies}) do
    {flow_props, new_policies} =
      flows
      |> Enum.map(
        fn({flow_name, flow_desc}) ->

          {flow_desc_res, np} = build(flow_desc, {[], []})

          {
            ("""
            <Flow name=<%= flow_name %>>
              <%= flow_desc_res %>
            </Flow>
            """ |> EEx.eval_string [
              flow_name: flow_name,
              flow_desc_res: flow_desc_res
            ]), np
          }
        end
      )
      |> Enum.reduce(
        {[], []},
        fn({flow, policy}, {flow_acc, policy_acc}) ->
          {[flow|flow_acc], policy ++ policy_acc}
        end
      )

    flows = ["<Flows>"] ++ flow_props ++ ["</Flows>\n"]

    build(rest, {flows ++ doc, new_policies ++ policies})
  end

  def build([{'request', props}|rest], {doc, policies}) do
    request = """
      <Request>
      <%= for item <- props do %>
        <Step><Name><%= item %></Name></Step>
      <% end %>
      </Request>
    """ |> EEx.eval_string [props: props]

    build(rest, {[request|doc], Enum.map(props, &to_string(&1)) ++ policies})
  end

  def build([{'response', :null}|rest], {doc, policies}) do
    build(rest, {["  <Response />"|doc], policies})
  end

  def build([{'response', props}|rest], {doc, policies}) do
    response = """
    <Response>
    <%= for item <- props do %>
      <Step><Name><%= item %></Name></Step>
    <% end %>
    </Response>
    """ |> EEx.eval_string [props: props]

    build(rest, {[response|doc], policies})
  end

  def build([{'path', path}, {'verb', verb}|rest], {doc, policies}) do
    match_condition = """
    <Condition>(proxy.pathsuffix MatchesPath "<%= path %>") and (request.verb = "<%= verb %>")</Condition>
    """
    |> EEx.eval_string [path: path, verb: verb]

    build(rest, {[match_condition|doc], policies})
  end

  def build([{'httpproxyconnection', props}|rest], {doc, policies}) do
    {httpproxy_props, pol} = build(props, {[], []})

    httpproxyconnection = """
    <HTTPProxyConnection>
    <%= props %>
    </HTTPProxyConnection>
    """ |> EEx.eval_string [props: httpproxy_props]

    build(rest, {[httpproxyconnection|doc], pol ++ policies})
  end

  def build([{'basepath', basepath}|rest], {doc, policies}) do
    base_path = """
      <BasePath><%= base_path %></BasePath>
      <VirtualHost>secure</VirtualHost>
    """ |> EEx.eval_string [base_path: basepath]

    build(rest, {[base_path|doc], policies})
  end

  def build([{'routerules', routerules}|rest], {doc, policies}) do
    route_rule_props =
      routerules
      |> Enum.flat_map(
         fn({route_name, route_desc}) ->

           {route_desc_res, pol} = build(route_desc, {[], []})

           [
           """
           <RouteRule name=<%= route_name %>>
             <%= route_desc_res %>
           </RouteRule>
           """ |> EEx.eval_string [
             route_name: route_name,
             route_desc_res: route_desc_res]
           ]
         end
      )

    build(rest, {route_rule_props ++ doc, policies})
  end

  def build([{'faultrules', faultrules}|rest], {doc, policies}) do
    new_policies =
      faultrules
      |> Enum.map(fn({_, [name, [{_,_}]]}) -> to_string(name) end)


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

    build(rest, {fault_rule_props ++ doc, new_policies ++ policies})
  end
end
