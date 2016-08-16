'use strict';

// Simple pure-React component so we don't have to remember
// Bootstrap's classes
var BootstrapButton = React.createClass({
  render: function() {
    return (
      <a {...this.props}
        href="javascript:;"
        role="button"
        className={(this.props.className || '') + ' btn'} />
    );
  }
});

var BootstrapModal = React.createClass({
  // The following two methods are the only places we need to
  // integrate Bootstrap or jQuery with the components lifecycle methods.
  componentDidMount: function() {
    // When the component is added, turn it into a modal
    $(this.refs.root).modal({backdrop: 'static', keyboard: false, show: false});

    // Bootstrap's modal class exposes a few events for hooking into modal
    // functionality. Lets hook into one of them:
    $(this.refs.root).on('hidden.bs.modal', this.handleHidden);
  },
  componentWillUnmount: function() {
    $(this.refs.root).off('hidden.bs.modal', this.handleHidden);
  },
  close: function() {
    $(this.refs.root).modal('hide');
  },
  open: function() {
    $(this.refs.root).modal('show');
  },
  render: function() {
    var confirmButton = null;
    var cancelButton = null;

    if (this.props.confirm) {
      confirmButton = (
        <BootstrapButton
          onClick={this.handleConfirm}
          className="btn-primary">
          {this.props.confirm}
        </BootstrapButton>
      );
    }
    if (this.props.cancel) {
      cancelButton = (
        <BootstrapButton onClick={this.handleCancel} className="btn-default">
          {this.props.cancel}
        </BootstrapButton>
      );
    }

    return (
      <div className="modal fade" ref="root">
        <div className="modal-dialog">
          <div className="modal-content">
            <div className="modal-header">
              <button
                type="button"
                className="close"
                onClick={this.handleCancel}>
                &times;
              </button>
              <h3>{this.props.title}</h3>
            </div>
            <div className="modal-body">
              {this.props.children}
            </div>
            <div className="modal-footer">
              {cancelButton}
              {confirmButton}
            </div>
          </div>
        </div>
      </div>
    );
  },
  handleCancel: function() {
    if (this.props.onCancel) {
      this.props.onCancel();
    }
  },
  handleConfirm: function() {
    if (this.props.onConfirm) {
      this.props.onConfirm();
    }
  },
  handleHidden: function() {
    if (this.props.onHidden) {
      this.props.onHidden();
    }
  }
});

var Example = React.createClass({
  handleCancel: function() {
    if (confirm('Are you sure you want to cancel?')) {
      this.refs.modal.close();
    }
  },
  render: function() {
    var modal = null;
    modal = (
      <BootstrapModal
        ref="modal"
        confirm="OK"
        cancel="Cancel"
        onCancel={this.handleCancel}
        onConfirm={this.closeModal}
        onHidden={this.handleModalDidClose}
        title="Hello, Bootstrap!">
          This is a React component powered by jQuery and Bootstrap!
      </BootstrapModal>
    );
    return (
      <div className="example">
        {modal}
        <BootstrapButton onClick={this.openModal} className="btn-default">
          Open modal
        </BootstrapButton>
      </div>
    );
  },
  openModal: function() {
    this.refs.modal.open();
  },
  closeModal: function() {
    this.refs.modal.close();
  },
  handleModalDidClose: function() {
    alert("The modal has been dismissed!");
  }
});

var SigninForm = React.createClass({
  getInitialState: function (argument) {
    // body...
    return {
      is_save_user: false,
      user_email: "",
      user_password: "",
    };
  },
  handleConfirm: function (argument) {
    // body...
    try {
      $.post("/test", {}, function (resp) {
        // body...
        console.log("Hello");
        var abc = resp.id;
        var sabc = abc.toString();
        // ReactDOM.render(<Example1 name={sabc}/>, document.getElementById("jqueryexample"))
      }, "json")
    } catch (e) {
      console.log("abc")
    }
  },
  handleCheck: function (argument) {
    // body...
  },
  handleChange: function (e) {
    // body...
    // e.target.value
    if (this.state.is_save_user) {
      var user_email = this.refs.user_email.value;
      var user_password = this.refs.user_password.value;
      this.setState({
        is_save_user:false,
      });
    } else {
      this.setState({
        is_save_user:true,
        user_email:user_email,
        user_password:user_password,
      });
    }
  }.bind(this),
  render: function (argument) {
    // body...
    return (
      <div className="form-signin">
        <h2 className="form-signin-heading">Please sign in</h2>
        <input ref="user_email" type="text" className="input-block-level" placeholder="Email address"/>
        <input ref="user_password" type="password" className="input-block-level" placeholder="Password"/>
        <label className="checkbox">
          <input type="checkbox" value="remember-me" onChange={this.handleChange}/>
          Remember me
        </label>
        <button className="btn btn-large btn-primary" onClick={this.handleConfirm}>Sign in</button>
      </div>
    );
  }
});

class Example1 extends React.Component {
  render() {
    return (
      <div>Hello {this.props.name}</div>
      );
  }
}

var Example2 = React.createClass({
  handleConfirm:function (argument) {
    // body...
    // $.get("/test", {}, function (resp) {
    //   // body...
    //   console.log("Hello");
    //   var abc;
    //   if (typeof(resp) == "stirng") {
    //     name = resp
    //   }
    //   ReactDOM.render(<Example1 name={abc}/>, document.getElementById("jqueryexample"))
    // });
    $.post("/test", {}, function (resp) {
      // body...
      console.log("Hello");
      var abc = resp.id;
      var sabc = abc.toString();
      ReactDOM.render(<Example1 name={sabc}/>, document.getElementById("jqueryexample"))
    }, "json")
  },
  render:function (argument) {
    // body...
    return (
      <button type="button" className="btn btn-default" onClick={this.handleConfirm}>confirm</button>
      );
  }
});

var Navbar = React.createClass({
  render:function (argument) {
    // body...
    return (
      <div className="navbar navbar-inverse navbar-fixed-top">
        <div className="navbar-inner">
          <div className="container-fluid">
            <button type="button" className="btn btn-navbar" data-toggle="collapse" data-target=".nav-collapse">
              <span className="icon-bar"></span>
              <span className="icon-bar"></span>
              <span className="icon-bar"></span>
            </button>
            <a className="brand" href="#">Project name</a>
            <div className="nav-collapse collapse">
              <p className="navbar-text pull-right">
                Logged in as <a href="#" className="navbar-link">Username</a>
              </p>
              <ul className="nav">
                <li className="active"><a href="#">Home</a></li>
                <li><a href="#about">About</a></li>
                <li><a href="#contact">Contact</a></li>
              </ul>
            </div>
          </div>
        </div>
      </div>
      );
  }
});

var Span4 = React.createClass({
  render:function (argument) {
    // body...
    return (
      <div className="span4">
        <h2>{this.props.heading}</h2>
        <p>{this.props.content}</p>
        <p><a className="btn" href="#">View details &raquo;</a></p>
      </div>
      );
  }
});

var RowFluid = React.createClass({
  render:function (argument) {
    // body...
    return (
      <div className="row-fluid">
        <Span4 heading="Heading" content="AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"/>
        <Span4 heading="Heading" content="AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"/>
        <Span4 heading="Heading" content="AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"/>
      </div>
      );
  }
});

var Span3 = React.createClass({
  render: function (argument) {
    // body...
    return (
      <div className="span3">
        <div className="well sidebar-nav">
          <ul className="nav nav-list">
            <li className="nav-header">Sidebar</li>
            <li className="active"><a href="#">Link</a></li>
            <li><a href="#">Link</a></li>
            <li><a href="#">Link</a></li>
            <li><a href="#">Link</a></li>
            <li class="nav-header">Sidebar</li>
            <li><a href="#">Link</a></li>
            <li><a href="#">Link</a></li>
            <li><a href="#">Link</a></li>
            <li><a href="#">Link</a></li>
            <li><a href="#">Link</a></li>
            <li><a href="#">Link</a></li>
            <li class="nav-header">Sidebar</li>
            <li><a href="#">Link</a></li>
            <li><a href="#">Link</a></li>
            <li><a href="#">Link</a></li>
          </ul>
          <ul className="nav-header">Sidebar</ul>
        </div>
      </div>
    );  
  }
});

var Span9 = React.createClass({
  render:function (argument) {
    // body...
    return (
      <div className="span9">
        <div className="hero-unit">
          <h1>Hello, world!</h1>
          <p>This is a template for a simple marketing or informational website. It includes a large callout called the hero unit and three supporting pieces of content. Use it as a starting point to create something more unique.</p>
          <p><a href="#" className="btn btn-primary btn-large">Learn more &raquo;</a></p>
        </div>
        <RowFluid />
        <RowFluid />
      </div>
      );
  }
});

var ContainerFluid = React.createClass({
  render:function (argument) {
    // body...
    return (
      <div className="container-fluid">
        <div className="row-fluid">
          <Span3 />
          <Span9 />
        </div>
      </div>
      );
  }
});

var Root = React.createClass({
  render: function (argument) {
    // body...
    return (
      <div>
        <Navbar />
        <ContainerFluid />
      </div>
      );
  }
});

class ToolItem extends React.Component {
  getValue() {
    return this.refs.tool_mtext.value
  }
  render() {
    return (
      <form>
        <div className="form-group">
          <label htmlFor="inputEmail3" className="col-sm-2 control-label">{this.props.title}</label>
          <div className="col-sm-10">
            <input ref="tool_mtext" type="email" className="form-control" id="inputEmail3" placeholder="Email" />
          </div>
        </div>
        <button ref="tool_valid" type="button" className="btn btn-default" onClick={this.props.onClick}>submit</button>
      </form>
      );
  }
}

class Tool extends React.Component {
  // static defaultProps = {
  // }
  // state = {
  // }

  constructor(props) {
    super(props);
    // Operations usually carried out in componentWillMount go here
    this.text1 = this.text1.bind(this)
  }

  onValidation() {
    // debugger
    console.log("text1");
    var table_name = this.refs.validation.getValue();
    $.post("/validation", {table_name:table_name}, function (resp) {
      // body...
      console.log("Hello");
      // var abc = resp.id;
      // var sabc = abc.toString();
      // ReactDOM.render(<Example1 name={sabc}/>, document.getElementById("jqueryexample"))
    }, "json")
  }
  onValidationRo() {
    var table_name = this.refs.validation.getValue();
    $.post("/validation_ro", {table_name:table_name}, function (resp) {
      // body...
      console.log(resp.errorcode);
    }, "json");
  }
  onPercudure() {
    var table_name = this.refs.percudure.getValue();
    $.post("/percudure", {table_name:table_name}, function (resp) {
      // body...
      console.log(resp.errorcode);
    }, "json")
  }
  render() {
    return (
      <div className="container-fluid">
        <div className="row">
          <ToolItem ref="validation" title="validation" onClick={this.onValidation} />
        </div>
        <div className="row">
          <ToolItem ref="validation_ro" title="validation_ro" onClick={this.onValidationRo} />
        </div>
        <div className="row">
          <ToolItem ref="percudure" title="percudure" onClick={this.onPercudure} />
        </div>
      </div>
      );
  }
}

class Email extends React.Component {
  constructor(props) {
    super(props);
    // Operations usually carried out in componentWillMount go here
    // this.text1 = this.text1.bind(this)
  }
  render() {
    return (
      <div>
        <div className="input-group">
          <span className="input-group-addon" id="basic-addon1">@</span>
          <input type="text" className="form-control" placeholder="Username" aria-describedby="basic-addon1" />
        </div>
        <div className="input-group">
        </div>
      </div>
      );
  }
}

ReactDOM.render(<Tool />, document.getElementById('root'));
