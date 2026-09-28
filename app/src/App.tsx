import { Route, Routes } from "react-router-dom";
import { Layout } from "./components/Layout";
import { TableauBord } from "./pages/TableauBord";
import { Liste } from "./pages/Liste";
import { Detail } from "./pages/Detail";
import { NouvelleDemande } from "./pages/NouvelleDemande";

function App() {
  return (
    <Layout>
      <Routes>
        <Route path="/" element={<TableauBord />} />
        <Route path="/liste" element={<Liste />} />
        <Route path="/detail/:id" element={<Detail />} />
        <Route path="/nouvelle" element={<NouvelleDemande />} />
      </Routes>
    </Layout>
  );
}

export default App;
